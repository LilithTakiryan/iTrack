//
//  AppendLocationUseCaseProtocol.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//


protocol AppendLocationUseCaseProtocol {
    func execute(_ location: LocationPoint, for routeId: Route.ID) async throws
}

final class AppendLocationUseCase: AppendLocationUseCaseProtocol {
    private let repository: LocationRepository
    
    init(repository: LocationRepository) {
        self.repository = repository
    }
    
    func execute(_ location: LocationPoint, for routeId: Route.ID) async throws {
        try await repository.addLocation(location, to: routeId)
    }
}