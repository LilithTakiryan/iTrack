//
//  TrackedLocationsViewModel.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import Foundation
import Observation

@MainActor
@Observable
final class LocationsListViewModel {
    var routes: [Route] = []
    
    @ObservationIgnored private let repository: LocationRepository

    init(repository: LocationRepository) {
        self.repository = repository
    }

    func fetchRoutes() async {
        do {
            routes = try await repository.fetchRoutes()
        } catch {
            print("Failed to fetch routes:", error)
        }
    }

    func delete(offsets: IndexSet) {
        let routesToDelete = offsets.map { routes[$0] }
        
        Task {
            for route in routesToDelete {
                do {
                    try await repository.deleteRoute(id: route.id)
                } catch {
                    print("Failed to delete route \(route.id):", error)
                }
            }
            await fetchRoutes()
        }
    }
}
