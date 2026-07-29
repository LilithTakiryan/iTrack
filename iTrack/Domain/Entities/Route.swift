//
//  Route.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//


import Foundation

public struct Route: Identifiable, Sendable {
    public let id: UUID
    public let startedAt: Date
    public var endedAt: Date?
    public var locations: [LocationPoint]

    public init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        locations: [LocationPoint] = []
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.locations = locations
    }
}