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
            result.statusText = status
            result.isTrackingRequested = isRequested
            result.showLocationPermissionAlert = false
            result.lastErrorMessage = nil
            result.trackingState = TrackingStateResolver.resolve(statusText: status, isTrackingRequested: isRequested)
            
        case let .requireSettings(message):
            result.statusText = message
            result.isTrackingRequested = false
            result.showLocationPermissionAlert = true
            result.lastErrorMessage = message
            result.trackingState = .requiresSettings
            
        case let .trackingError(message):
            result.statusText = message
            result.isTrackingRequested = false
            result.showLocationPermissionAlert = false
            result.lastErrorMessage = message
            result.trackingState = .serviceError
            
        case let .locationReceived(location):
            result.lastLocation = location
            result.newLocationToAppend = location
            
        case .rejectedLocation:
            result.didRejectLocation = true
        }
        
        return result
    }
}