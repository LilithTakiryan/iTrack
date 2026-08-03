//
//  TrackingStateResolverTests.swift
//  iTrackTests
//
//  Created by lilit on 03.08.26.
//

import Testing
@testable import iTrack

struct TrackingStateResolverTests {

    @Test("Requesting permission state")
    func testRequestingState() {
        let s1 = TrackingStateResolver.resolve(statusText: "Starting...", isTrackingRequested: true)
        #expect(s1 == .requestingPermission)
        
        let s2 = TrackingStateResolver.resolve(statusText: "Requesting location permission", isTrackingRequested: true)
        #expect(s2 == .requestingPermission)
    }

    @Test("Paused state")
    func testPausedState() {
        let s = TrackingStateResolver.resolve(statusText: "Tracking paused in background", isTrackingRequested: true)
        #expect(s == .paused)
    }

    @Test("Requires settings state")
    func testSettingsRequiredState() {
        let messages = [
            "Permission required",
            "Background permission needed",
            "Location services are disabled",
            "Location services are unavailable"
        ]
        
        for msg in messages {
            let s = TrackingStateResolver.resolve(statusText: msg, isTrackingRequested: true)
            #expect(s == .requiresSettings)
        }
    }

    @Test("Service error state")
    func testErrorState() {
        let s1 = TrackingStateResolver.resolve(statusText: "General Error occurred", isTrackingRequested: true)
        #expect(s1 == .serviceError)
        
        let s2 = TrackingStateResolver.resolve(statusText: "GPS is unavailable", isTrackingRequested: true)
        #expect(s2 == .serviceError)
    }

    @Test("Idle vs Tracking fallback")
    func testFallbackState() {
        // Normal status, tracking requested
        let s1 = TrackingStateResolver.resolve(statusText: "Normal", isTrackingRequested: true)
        #expect(s1 == .tracking)
        
        // Normal status, tracking NOT requested
        let s2 = TrackingStateResolver.resolve(statusText: "Not tracking", isTrackingRequested: false)
        #expect(s2 == .idle)
    }
}
