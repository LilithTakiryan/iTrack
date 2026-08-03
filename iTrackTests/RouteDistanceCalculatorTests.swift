//
//  RouteDistanceCalculatorTests.swift
//  iTrackTests
//
//  Created by lilit on 03.08.26.
//

import Testing
import CoreLocation
@testable import iTrack

struct RouteDistanceCalculatorTests {

    @Test("Distance for empty list should be 0")
    func testEmptyList() {
        let distance = RouteDistanceCalculator.distance(for: [])
        #expect(distance == 0)
    }

    @Test("Distance for single point should be 0")
    func testSinglePoint() {
        let point = LocationPoint(latitude: 41.7151, longitude: 44.8271, accuracy: 10, timestamp: Date())
        let distance = RouteDistanceCalculator.distance(for: [point])
        #expect(distance == 0)
    }

    @Test("Distance calculation should sort by timestamp")
    func testSortingAndCalculation() {
        let now = Date()
        let p1 = LocationPoint(latitude: 41.7151, longitude: 44.8271, accuracy: 10, timestamp: now)
        // Approx 1km North
        let p2 = LocationPoint(latitude: 41.7241, longitude: 44.8271, accuracy: 10, timestamp: now.addingTimeInterval(10))
        
        // Input out of order
        let distance = RouteDistanceCalculator.distance(for: [p2, p1])
        
        // Expected distance is ~1000 meters
        #expect(distance > 990 && distance < 1010)
    }

    @Test("Metric formatting")
    func testMetricFormatting() {
        let now = Date()
        let p1 = LocationPoint(latitude: 41.7151, longitude: 44.8271, accuracy: 10, timestamp: now)
        let p2 = LocationPoint(latitude: 41.7160, longitude: 44.8271, accuracy: 10, timestamp: now.addingTimeInterval(10))
        
        let shortDist = RouteDistanceCalculator.formattedDistance(for: [p1, p2], unit: .metric)
        #expect(shortDist.contains("m"))
        #expect(!shortDist.contains("km"))
        
        // Long distance ~1.1km
        let p3 = LocationPoint(latitude: 41.7251, longitude: 44.8271, accuracy: 10, timestamp: now.addingTimeInterval(20))
        let longDist = RouteDistanceCalculator.formattedDistance(for: [p1, p3], unit: .metric)
        #expect(longDist.contains("km"))
        #expect(longDist.contains("1.11")) // 41.7251 - 41.7151 is 0.01 deg lat ~= 1.11km
    }

    @Test("Imperial formatting")
    func testImperialFormatting() {
        let now = Date()
        // ~100 meters ~= 328 feet
        let p1 = LocationPoint(latitude: 41.7151, longitude: 44.8271, accuracy: 10, timestamp: now)
        let p2 = LocationPoint(latitude: 41.7160, longitude: 44.8271, accuracy: 10, timestamp: now.addingTimeInterval(10))
        
        let feetDist = RouteDistanceCalculator.formattedDistance(for: [p1, p2], unit: .imperial)
        #expect(feetDist.contains("ft"))
        
        // ~2km ~= 1.24 miles
        let p3 = LocationPoint(latitude: 41.7331, longitude: 44.8271, accuracy: 10, timestamp: now.addingTimeInterval(30))
        let milesDist = RouteDistanceCalculator.formattedDistance(for: [p1, p3], unit: .imperial)
        #expect(milesDist.contains("mi"))
    }
}
