//
//  SaveLocationUseCase.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//


import Foundation

public struct SaveLocationUseCase: Sendable {
    private let repository: LocationRepository

    public init(repository: LocationRepository) {
        self.repository = repository
    }

    public func execute(location: LocationPoint, routeId: UUID) async throws {
        try await repository.addLocation(location, to: routeId)
    }
}