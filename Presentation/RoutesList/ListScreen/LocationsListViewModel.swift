//
//  LocationsListViewModel.swift
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
        AppLogger.shared.debug("Fetching routes")
        do {
            routes = try await repository.fetchRoutes()
            AppLogger.shared.debug("Loaded \(routes.count) routes")
        } catch {
            AppLogger.shared.error("Failed to fetch routes: \(error.localizedDescription)")
        }
    }
    
    func delete(offsets: IndexSet) {
        let routesToDelete = offsets.map { routes[$0] }
        AppLogger.shared.debug("Deleting \(routesToDelete.count) routes")
        
        Task {
            for route in routesToDelete {
                do {
                    try await repository.deleteRoute(id: route.id)
                    AppLogger.shared.debug("Route deleted: \(route.id)")
                } catch {
                    AppLogger.shared.error("Failed to delete route \(route.id): \(error.localizedDescription)")
                }
            }
            await fetchRoutes()
        }
    }
}
