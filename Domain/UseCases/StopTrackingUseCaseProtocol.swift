//
//  StopTrackingUseCaseProtocol.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//


import Foundation

public protocol StopTrackingUseCaseProtocol: Sendable {
    func execute(routeId: UUID) async throws -> Int
}

public final class StopTrackingUseCase: StopTrackingUseCaseProtocol {
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
    
    public func execute(routeId: UUID) async throws -> Int {
        await trackerService.stopTracking()
        let finalSteps = stepCounter.stop()

        try await repository.updateSteps(finalSteps, routeId: routeId)
        
        return finalSteps
    }
}
