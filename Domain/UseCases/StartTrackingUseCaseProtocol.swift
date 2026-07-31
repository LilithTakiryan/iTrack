//
//  StartTrackingUseCaseProtocol.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//


import Foundation

public protocol StartTrackingUseCaseProtocol: Sendable {
    func execute(mode: TrackingMode) async throws -> Route
}

public final class StartTrackingUseCase: StartTrackingUseCaseProtocol {
    private let repository: LocationRepository
    private let trackerService: LocationTrackingService
    private let stepCounter: StepCounter

    public init(
        repository: LocationRepository,
        trackerService: LocationTrackingService,
        stepCounter: StepCounter
    ) {
        self.repository = repository
        self.trackerService = trackerService
        self.stepCounter = stepCounter
    }

    public func execute(mode: TrackingMode) async throws -> Route {
        let route = try await repository.createRoute()
        stepCounter.start(from: route.startedAt)
        await trackerService.startTracking(mode: mode)
        return route
    }
}
