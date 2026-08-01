//
//  TrackingEventReducer.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//


struct TrackingEventReducer {
    
    struct Result {
        var statusText: String?
        var isTrackingRequested: Bool?
        var showLocationPermissionAlert: Bool?
        var lastErrorMessage: String?
        var trackingState: TrackingState?
        var lastLocation: LocationPoint?
        var newLocationToAppend: LocationPoint?
        var didRejectLocation: Bool = false
    }
    
    static func reduce(_ event: LocationTrackingEvent) -> Result {
        var result = Result()
        
        switch event {
        case let .statusUpdated(status, isRequested):
            AppLogger.shared.debug("Status updated: \(status), isTrackingRequested: \(isRequested)")
            result.statusText = status
            result.isTrackingRequested = isRequested
            result.showLocationPermissionAlert = false
            result.lastErrorMessage = nil
            result.trackingState = TrackingStateResolver.resolve(statusText: status, isTrackingRequested: isRequested)
            
        case let .requireSettings(message):
            AppLogger.shared.debug("Settings required: \(message)")
            result.statusText = message
            result.isTrackingRequested = false
            result.showLocationPermissionAlert = true
            result.lastErrorMessage = message
            result.trackingState = .requiresSettings
            
        case let .trackingError(message):
            AppLogger.shared.error("Tracking error: \(message)")
            result.statusText = message
            result.isTrackingRequested = false
            result.showLocationPermissionAlert = false
            result.lastErrorMessage = message
            result.trackingState = .serviceError
            
        case let .locationReceived(location):
            AppLogger.shared.debug("Location: locationReceived")
            result.lastLocation = location
            result.newLocationToAppend = location
            
        case .rejectedLocation:
            AppLogger.shared.debug("Location rejected")
            result.didRejectLocation = true
        }
        
        return result
    }
}
