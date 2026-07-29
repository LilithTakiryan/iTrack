//
//  Route.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//


import Foundation
import SwiftData

@Model
final class Route {
    var id: UUID = UUID()
    var startedAt: Date
    var name: String

    @Relationship(deleteRule: .cascade)
    var locations: [TrackedLocation] = []

    init(startedAt: Date = .now) {
        self.startedAt = startedAt

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        self.name = formatter.string(from: startedAt)
    }
}