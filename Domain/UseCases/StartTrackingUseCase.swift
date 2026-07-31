//
//  StartTrackingUseCase.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//


import Foundation

public struct StartTrackingUseCase: Sendable {
    private let repository: LocationRepository
    private let tracker: LocationTrackingService

    public init(repository: LocationRepository, tracker: LocationTrackingService) {
        self.repository = repository
        self.tracker = tracker
    }

    public func execute(mode: TrackingMode) async throws -> Route {
        let newRoute = try await repository.createRoute()
        await tracker.startTracking(mode: mode)
        return newRoute
    }
}