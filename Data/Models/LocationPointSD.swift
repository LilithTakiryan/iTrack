//
//  LocationPointSD 2.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//


import Foundation
import SwiftData

@Model
public final class LocationPointSD {
    @Attribute(.unique) public var id: UUID
    public var latitude: Double
    public var longitude: Double
    public var accuracy: Double
    public var timestamp: Date
    public var route: RouteSD?

    public init(
        id: UUID = UUID(),
        latitude: Double,
        longitude: Double,
        accuracy: Double,
        timestamp: Date,
        route: RouteSD? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
        self.timestamp = timestamp
        self.route = route
    }

    public func toDomain() -> LocationPoint {
        LocationPoint(
            id: id,
            latitude: latitude,
            longitude: longitude,
            accuracy: accuracy,
            timestamp: timestamp
        )
    }
}