//
//  Route.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//

import Foundation

public struct Route: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let startedAt: Date
    public var endedAt: Date
    public var steps: Int
    public var locations: [LocationPoint]

    public init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        endedAt: Date = Date(),
        steps: Int = 0,
        locations: [LocationPoint] = []
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.steps = steps
        self.locations = locations
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(startedAt)
        hasher.combine(locations.count)
    }
}
