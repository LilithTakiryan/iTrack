//
//  CoreLocationService.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import CoreLocation
import Foundation

@MainActor
public final class CoreLocationService: NSObject, LocationTrackingService {
    public let events: AsyncStream<LocationTrackingEvent>
    private let continuation: AsyncStream<LocationTrackingEvent>.Continuation

    private let manager = CLLocationManager()
    private var isTracking = false
    private var isTrackingRequested = false
    private var didRequestBackgroundPermission = false
    private var selectedMode: TrackingMode = .foreground
    private var lastEmittedLocation: CLLocation?

    public override init() {
        var streamContinuation: AsyncStream<LocationTrackingEvent>.Continuation!
        self.events = AsyncStream { cont in
            streamContinuation = cont
        }
        self.continuation = streamContinuation

        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.pausesLocationUpdatesAutomatically = false
    }

    public func startTracking(mode: TrackingMode) {
        selectedMode = mode
        isTrackingRequested = true
        send(.statusUpdated(statusText: "Starting", isTrackingRequested: true))

        if manager.authorizationStatus == .notDetermined {
            send(.statusUpdated(statusText: "Requesting permission", isTrackingRequested: true))
            manager.requestWhenInUseAuthorization()
            return
        }

        handleAuthorizationChange()
    }

    public func requestPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            send(.statusUpdated(statusText: "Requesting permission", isTrackingRequested: false))
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            requireSettings(message: "Location permission required")
        case .authorizedWhenInUse, .authorizedAlways:
            send(.statusUpdated(statusText: "Location permission already granted", isTrackingRequested: false))
        @unknown default:
            requireSettings(message: "Location permission required")
        }
    }

    public func stopTracking() {
        isTrackingRequested = false
        stopUpdates()
        send(.statusUpdated(statusText: "Not tracking", isTrackingRequested: false))
    }

    public func handleScenePhase(isBackground: Bool) {
        guard isTrackingRequested else { return }

        if isBackground, manager.authorizationStatus != .authorizedAlways {
            stopUpdates()
            send(.statusUpdated(statusText: "Paused in background", isTrackingRequested: true))
        } else if !isBackground {
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
            send(.statusUpdated(statusText: "Requesting background permission", isTrackingRequested: true))
            manager.requestAlwaysAuthorization()
        }
    }

    private func startUpdates(allowsBackground: Bool) {
        manager.allowsBackgroundLocationUpdates = allowsBackground

        if !isTracking {
            manager.startUpdatingLocation()
            isTracking = true
        }

        send(.statusUpdated(
            statusText: allowsBackground ? "Tracking in background" : "Tracking",
            isTrackingRequested: true
        ))
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
        send(.requireSettings(message: message))
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

    private func processLocation(_ location: CLLocation) {
        guard CLLocationCoordinate2DIsValid(location.coordinate),
              location.horizontalAccuracy >= 0,
              location.horizontalAccuracy <= 100,
              abs(location.timestamp.timeIntervalSinceNow) <= 30
        else {
            send(.rejectedLocation)
            return
        }

        lastEmittedLocation = location

        let domainPoint = LocationPoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            accuracy: location.horizontalAccuracy,
            timestamp: location.timestamp
        )

        send(.locationReceived(domainPoint))
    }

    private func send(_ event: LocationTrackingEvent) {
        continuation.yield(event)
    }
}

extension CoreLocationService: CLLocationManagerDelegate {
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor [weak self] in
            guard let self, isTrackingRequested else { return }
            self.handleAuthorizationChange()
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor [weak self] in
            guard let self, let location = locations.last else { return }
            self.processLocation(location)
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            if (error as? CLError)?.code == .denied {
                requireSettings(message: "Location permission required")
            } else {
                send(.statusUpdated(statusText: error.localizedDescription, isTrackingRequested: isTrackingRequested))
            }
        }
    }
}
