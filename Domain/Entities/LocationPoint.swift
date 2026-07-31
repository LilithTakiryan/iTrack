//
//  LocationPoint.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import Foundation

public struct LocationPoint: Sendable, Identifiable, Equatable {
    public let id: UUID
    public let latitude: Double
    public let longitude: Double
    public let accuracy: Double
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        latitude: Double,
        longitude: Double,
        accuracy: Double,
        timestamp: Date
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
        self.timestamp = timestamp
    }
}
