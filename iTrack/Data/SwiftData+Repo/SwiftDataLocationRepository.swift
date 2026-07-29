//
//  SwiftDataLocationRepository.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//


import Foundation
import SwiftData

@ModelActor
public actor SwiftDataLocationRepository: LocationRepository {
    public func createRoute() throws -> Route {
        let routeSD = RouteSD()
        modelContext.insert(routeSD)
        try modelContext.save()
        return routeSD.toDomain()
    }

    public func addLocation(_ location: LocationPoint, to routeId: UUID) throws {
        var descriptor = FetchDescriptor<RouteSD>(predicate: #Predicate { $0.id == routeId })
        descriptor.fetchLimit = 1

        guard let routeSD = try modelContext.fetch(descriptor).first else { return }

        let pointSD = LocationPointSD(
            id: location.id,
            latitude: location.latitude,
            longitude: location.longitude,
            accuracy: location.accuracy,
            timestamp: location.timestamp,
            route: routeSD
        )

        modelContext.insert(pointSD)
        try modelContext.save()
    }

    public func fetchRoutes() throws -> [Route] {
        let descriptor = FetchDescriptor<RouteSD>(sortBy: [SortDescriptor(\.startedAt, order: .reverse)])
        let results = try modelContext.fetch(descriptor)
        return results.map { $0.toDomain() }
    }

    public func deleteRoute(id: UUID) throws {
        var descriptor = FetchDescriptor<RouteSD>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1

        if let route = try modelContext.fetch(descriptor).first {
            modelContext.delete(route)
            try modelContext.save()
        }
    }
}
