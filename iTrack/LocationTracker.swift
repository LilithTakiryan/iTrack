//
//  LocationTracker.swift
//  iTrack
//
//  Created by Codex on 28.07.26.
//

import CoreLocation
import Foundation
import SwiftUI

enum TrackingMode: String, CaseIterable, Identifiable {
    case foreground
    case background

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum LocationTrackerEvent {
    case status(String, isTrackingRequested: Bool)
    case requireSettings(String)
    case location(LocationSnapshot)
    case rejectedLocation
}

struct LocationSnapshot {
    let latitude: Double
    let longitude: Double
    let accuracy: CLLocationAccuracy
    let timestamp: Date
}

@MainActor
final class LocationTracker: NSObject {
    let events: AsyncStream<LocationTrackerEvent>
    private let eventContinuation: AsyncStream<LocationTrackerEvent>.Continuation
    private var lastEmittedLocation: CLLocation?
    private let manager = CLLocationManager()
    private var isTracking = false
    private var isTrackingRequested = false
    private var didRequestBackgroundPermission = false
    private var selectedMode: TrackingMode = .foreground

    override init() {
        var continuation: AsyncStream<LocationTrackerEvent>.Continuation!
        self.events = AsyncStream { cont in
            continuation = cont
        }
        self.eventContinuation = continuation

        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.pausesLocationUpdatesAutomatically = false
    }

    var permissionAlertMessage: String {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            return "Location permission is denied. Please allow location access in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            return "Location permission already granted."
        case .notDetermined:
            return "iTrack needs location permission to track your route. Please allow location access in Settings."
        @unknown default:
            return "iTrack needs location permission to track your route. Please allow location access in Settings."
        }
    }

    func startTracking(mode: TrackingMode) {
        selectedMode = mode
        isTrackingRequested = true
        send(.status("Starting", isTrackingRequested: true))

        // Removed guard CLLocationManager.locationServicesEnabled() check

        // If permission hasn't been determined yet, ask and wait for the delegate callback
        if manager.authorizationStatus == .notDetermined {
            send(.status("Requesting permission", isTrackingRequested: true))
            manager.requestWhenInUseAuthorization()
            return
        }

        // Defer the rest of the flow to the authorization-change handler to avoid
        // doing potentially blocking work synchronously here.
        handleAuthorizationChange()
    }

    func requestLocationPermission() {

        switch manager.authorizationStatus {
        case .notDetermined:
            send(.status("Requesting permission", isTrackingRequested: false))
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            requireSettings(message: "Location permission required")
        case .authorizedWhenInUse, .authorizedAlways:
            send(.status("Location permission already granted", isTrackingRequested: false))
        @unknown default:
            requireSettings(message: "Location permission required")
        }
    }

    func stopTracking() {
        isTrackingRequested = false
        stopUpdates()
        send(.status("Not tracking", isTrackingRequested: false))
    }

    func handleScenePhase(_ phase: ScenePhase) {
        guard isTrackingRequested else { return }

        if phase == .background, manager.authorizationStatus != .authorizedAlways {
            stopUpdates()
            send(.status("Paused in background", isTrackingRequested: true))
        } else if phase == .active {
            startTracking(mode: selectedMode)
        }
    }

    private func startWhenInUseTracking() {
        guard selectedMode == .background else {
            startUpdates(allowsBackground: false)
            return
        }

        if didRequestBackgroundPermission {
            requireSettings(message: "Background permission required")
        } else {
            didRequestBackgroundPermission = true
            send(.status("Requesting background permission", isTrackingRequested: true))
            manager.requestAlwaysAuthorization()
        }
    }

    private func startUpdates(allowsBackground: Bool) {
        manager.allowsBackgroundLocationUpdates = allowsBackground

        if !isTracking {
            manager.startUpdatingLocation()
            isTracking = true
        }

        send(.status(allowsBackground ? "Tracking in background" : "Tracking", isTrackingRequested: true))
    }

    private func stopUpdates() {
        if isTracking {
            manager.stopUpdatingLocation()
            isTracking = false
        }

        manager.allowsBackgroundLocationUpdates = false
    }

    private func requireSettings(message: String) {
        isTrackingRequested = false
        stopUpdates()
        send(.requireSettings(message))
    }

    private func handleAuthorizationChange() {

        switch manager.authorizationStatus {
        case .denied, .restricted:
            requireSettings(message: "Location permission required")
        case .authorizedWhenInUse:
            startWhenInUseTracking()
        case .authorizedAlways:
            startUpdates(allowsBackground: selectedMode == .background)
        case .notDetermined:
            break
        @unknown default:
            requireSettings(message: "Location permission required")
        }
    }

    private func use(_ location: CLLocation) {
        guard CLLocationCoordinate2DIsValid(location.coordinate),
              location.horizontalAccuracy >= 0,
              location.horizontalAccuracy <= 100,
              abs(location.timestamp.timeIntervalSinceNow) <= 30
        else {
            send(.rejectedLocation)
            return
        }

        if let last = lastEmittedLocation {
            _ = last.distance(from: location)

            // Ignore insignificant movement if less than 5 meters
//            if distance < 5 { //TODO: uncomment
//                return
//            }
        }

        lastEmittedLocation = location

        send(.location(
            LocationSnapshot(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                accuracy: location.horizontalAccuracy,
                timestamp: location.timestamp
            )
        ))
    }

    private func send(_ event: LocationTrackerEvent) {
        eventContinuation.yield(event)
    }
}

extension LocationTracker: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor [weak self] in
            guard let self, isTrackingRequested else { return }
            self.handleAuthorizationChange()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor [weak self] in
            guard let self, let location = locations.last else { return }
            use(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            guard let self else { return }

            if (error as? CLError)?.code == .denied {
                requireSettings(message: "Location permission required")
            } else {
                send(.status(error.localizedDescription, isTrackingRequested: isTrackingRequested))
            }
        }
    }
}
