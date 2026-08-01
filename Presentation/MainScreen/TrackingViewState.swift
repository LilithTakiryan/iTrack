//
//  TrackingViewState.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//

import Foundation
import Observation
import MapKit

@MainActor
@Observable
final class TrackingViewState {
    var selectedMode: TrackingMode = .foreground
    var statusText = LocationTrackingMessage.notTracking.rawValue
    var lastErrorMessage: String?
    var showLocationPermissionAlert = false
    var isTrackingRequested = false
    var trackingState: TrackingState = .idle
    
    var lastLocation: LocationPoint?
    var liveLocations: [LocationPoint] = []
    var rejectedLocationCount = 0
    var steps: Int = 0
    
    func reset() {
        liveLocations.removeAll()
        lastLocation = nil
        rejectedLocationCount = 0
        steps = 0
    }
}
