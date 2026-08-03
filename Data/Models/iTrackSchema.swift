//
//  iTrackSchema.swift
//  iTrack
//
//  Created by lilit on 03.08.26.
//

import Foundation
import SwiftData

public enum iTrackSchemaV1: VersionedSchema {
    public static var versionIdentifier = Schema.Version(1, 0, 0)
    public static var models: [any PersistentModel.Type] = [RouteSD.self, LocationPointSD.self]

    @Model
    public final class RouteSD {
        @Attribute(.unique) public var id: UUID
        public var startedAt: Date
        public var endedAt: Date
        public var steps: Int

        @Relationship(deleteRule: .cascade, inverse: \LocationPointSD.route)
        public var locations: [LocationPointSD]

        public init(
            id: UUID = UUID(),
            startedAt: Date = Date(),
            endedAt: Date = Date(),
            steps: Int = 0
        ) {
            self.id = id
            self.startedAt = startedAt
            self.endedAt = endedAt
            self.steps = steps
            self.locations = []
        }
        
        public func toDomain() -> Route {
            Route(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                steps: steps,
                locations: locations.map { $0.toDomain() }
            )
        }
    }

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
}
