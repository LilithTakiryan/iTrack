//
//  TrackingEventReducerTests.swift
//  iTrackTests
//
//  Created by lilit on 03.08.26.
//

import Testing
import Foundation
@testable import iTrack

struct TrackingEventReducerTests {

    @Test("Status updated event")
    func testStatusUpdated() {
        let event = LocationTrackingEvent.statusUpdated(statusText: "Starting", isTrackingRequested: true)
        let result = TrackingEventReducer.reduce(event)
        
        #expect(result.statusText == "Starting")
        #expect(result.isTrackingRequested == true)
        #expect(result.showLocationPermissionAlert == false)
        #expect(result.trackingState == .requestingPermission)
    }

    @Test("Require settings event")
    func testRequireSettings() {
        let msg = "Permission required"
        let event = LocationTrackingEvent.requireSettings(message: msg)
        let result = TrackingEventReducer.reduce(event)
        
        #expect(result.statusText == msg)
        #expect(result.isTrackingRequested == false)
        #expect(result.showLocationPermissionAlert == true)
        #expect(result.trackingState == .requiresSettings)
    }

    @Test("Location received event")
    func testLocationReceived() {
        let point = LocationPoint(latitude: 10, longitude: 20, accuracy: 5, timestamp: Date())
        let event = LocationTrackingEvent.locationReceived(point)
        let result = TrackingEventReducer.reduce(event)
        
        #expect(result.lastLocation == point)
        #expect(result.newLocationToAppend == point)
    }

    @Test("Rejected location event")
    func testRejectedLocation() {
        let event = LocationTrackingEvent.rejectedLocation
        let result = TrackingEventReducer.reduce(event)
        
        #expect(result.didRejectLocation == true)
    }

    @Test("Tracking error event")
    func testTrackingError() {
        let msg = "Fatal Error"
        let event = LocationTrackingEvent.trackingError(message: msg)
        let result = TrackingEventReducer.reduce(event)
        
        #expect(result.statusText == msg)
        #expect(result.isTrackingRequested == false)
        #expect(result.trackingState == .serviceError)
    }
}
