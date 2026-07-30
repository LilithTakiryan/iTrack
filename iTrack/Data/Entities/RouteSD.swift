//
//  RouteSD.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//


import Foundation
import SwiftData

@Model
public final class RouteSD {
    @Attribute(.unique) public var id: UUID
    public var startedAt: Date
    public var endedAt: Date?
    public var steps: Int

    @Relationship(deleteRule: .cascade, inverse: \LocationPointSD.route)
    public var locations: [LocationPointSD]

    public init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        endedAt: Date? = nil,
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
