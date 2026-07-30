//
//  sampleData.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//

import Foundation

let baseLat = 37.334600
let baseLon = -122.009000
let now = Date()

let sampleLocations = [
    LocationPoint(
        id: UUID(),
        latitude: baseLat,
        longitude: baseLon,
        accuracy: 5.0,
        timestamp: now.addingTimeInterval(-20)
    ),
    LocationPoint(
        id: UUID(),
        latitude: baseLat + 0.00009, // ~10 meters
        longitude: baseLon,
        accuracy: 5.0,
        timestamp: now.addingTimeInterval(-10)
    ),
    LocationPoint(
        id: UUID(),
        latitude: baseLat + 0.00018, // ~20 meters
        longitude: baseLon,
        accuracy: 5.0,
        timestamp: now.addingTimeInterval(-10)
    ),
    LocationPoint(
        id: UUID(),
        latitude: baseLat + 0.00027, // ~30 meters total
        longitude: baseLon,
        accuracy: 5.0,
        timestamp: now
    ),
]

let sampleRoute = Route(
    id: UUID(),
    startedAt: Date().addingTimeInterval(-900),
    endedAt: Date(),
    locations: sampleLocations
)
