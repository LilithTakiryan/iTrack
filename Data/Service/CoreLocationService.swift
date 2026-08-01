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
    private var currentAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
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
        
        self.currentAuthorizationStatus = manager.authorizationStatus
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.pausesLocationUpdatesAutomatically = false
    }
    
    public func startTracking(mode: TrackingMode) {
        selectedMode = mode
        isTrackingRequested = true

        send(.statusUpdated(statusText: LocationTrackingMessage.starting.rawValue, isTrackingRequested: true))

        if currentAuthorizationStatus == .notDetermined {
            send(.statusUpdated(statusText: LocationTrackingMessage.requestingPermission.rawValue, isTrackingRequested: true))
            manager.requestWhenInUseAuthorization()
            return
        }

        handleAuthorizationChange()
    }

    public func requestPermission() {
        switch currentAuthorizationStatus {
        case .notDetermined:
            send(.statusUpdated(statusText: LocationTrackingMessage.requestingPermission.rawValue, isTrackingRequested: false))
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            requireSettings(message: .permissionRequired)
        case .authorizedWhenInUse, .authorizedAlways:
            send(.statusUpdated(statusText: LocationTrackingMessage.permissionGranted.rawValue, isTrackingRequested: false))
        @unknown default:
            requireSettings(message: .permissionRequired)
        }
    }

    public func handleScenePhase(isBackground: Bool) {
        guard isTrackingRequested else { return }

        if isBackground, currentAuthorizationStatus != .authorizedAlways {
            stopUpdates()
            send(.statusUpdated(statusText: LocationTrackingMessage.pausedInBackground.rawValue, isTrackingRequested: true))
        } else if !isBackground {
            startTracking(mode: selectedMode)
        }
    }

    private func handleAuthorizationChange() {
        switch currentAuthorizationStatus {
        case .denied, .restricted:
            requireSettings(message: .permissionRequired)
        case .authorizedWhenInUse:
            startWhenInUseTracking()
        case .authorizedAlways:
            startUpdates(allowsBackground: selectedMode == .background)
        case .notDetermined:
            break
        @unknown default:
            requireSettings(message: .permissionRequired)
        }
    }
    
    public func stopTracking() {
        isTrackingRequested = false
        stopUpdates()
        send(.statusUpdated(statusText: LocationTrackingMessage.notTracking.rawValue, isTrackingRequested: false))
    }
    
    private func startWhenInUseTracking() {
        guard selectedMode == .background else {
            startUpdates(allowsBackground: false)
            return
        }
        
        if didRequestBackgroundPermission {
            requireSettings(message: .backgroundPermissionRequired)
        } else {
            didRequestBackgroundPermission = true
            send(.statusUpdated(statusText: LocationTrackingMessage.requestingBackgroundPermission.rawValue, isTrackingRequested: true))
            manager.requestAlwaysAuthorization()
        }
    }
    
    private func startUpdates(allowsBackground: Bool) {
        manager.allowsBackgroundLocationUpdates = allowsBackground
        
        if !isTracking {
            manager.startUpdatingLocation()
            isTracking = true
        }
        
        let statusMessage: LocationTrackingMessage = allowsBackground ? .trackingInBackground : .tracking
        send(.statusUpdated(
            statusText: statusMessage.rawValue,
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
    
    private func requireSettings(message: LocationTrackingMessage) {
        isTrackingRequested = false
        stopUpdates()
        send(.requireSettings(message: message.rawValue))
    }
    
    private func processLocation(_ location: CLLocation) {
        guard CLLocationCoordinate2DIsValid(location.coordinate) else {
            send(.rejectedLocation)
            return
        }
        
        guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy <= 100 else {
            send(.rejectedLocation)
            return
        }
        
#if targetEnvironment(simulator)
        let maxAge: TimeInterval = 120 // 2 minutes for simulator testing
#else
        let maxAge: TimeInterval = 15  // 15 seconds for real-world movement
#endif
        
        guard abs(location.timestamp.timeIntervalSinceNow) <= maxAge else {
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

// MARK: - CLLocationManagerDelegate
extension CoreLocationService: CLLocationManagerDelegate {

    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        Task { @MainActor [weak self] in
            guard let self else { return }

            self.currentAuthorizationStatus = status

            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                if isTrackingRequested {
                    handleAuthorizationChange()
                }

            case .denied, .restricted:
                requireSettings(message: .permissionRequired)

            case .notDetermined:
                break

            @unknown default:
                break
            }
        }
    }

    nonisolated public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        Task { @MainActor [weak self] in
            self?.processLocation(location)
        }
    }

    nonisolated public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }

            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    requireSettings(message: .permissionRequired)

                case .locationUnknown:
                    fallthrough

                default:
                    send(.trackingError(
                        message: LocationTrackingMessage.serviceUnavailable.rawValue
                    ))
                }
            } else {
                send(.trackingError(message: error.localizedDescription))
            }
        }
    }
}
