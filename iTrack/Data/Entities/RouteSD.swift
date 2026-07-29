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
    
    @Relationship(deleteRule: .cascade, inverse: \LocationPointSD.route)
    public var locations: [LocationPointSD]

    public init(id: UUID = UUID(), startedAt: Date = Date(), endedAt: Date? = nil) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.locations = []
    }

    public func toDomain() -> Route {
        Route(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            locations: locations.map { $0.toDomain() }
        )
    }
}