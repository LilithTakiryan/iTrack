import Foundation
import SwiftData

protocol TrackingRepository {
    func createRoute() throws -> Route
    func saveLocation(_ location: LocationSnapshot, for route: Route) throws
    func fetchRoutes() throws -> [Route]
    func deleteRoute(_ route: Route) throws
}

@MainActor
final class SwiftDataTrackingRepository: TrackingRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func createRoute() throws -> Route {
        let route = Route()
        context.insert(route)
        try context.save()
        return route
    }

    func saveLocation(_ location: LocationSnapshot, for route: Route) throws {
        let entity = TrackedLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            timestamp: location.timestamp,
            accuracy: location.accuracy,
            altitude: nil,
            speed: nil,
            course: nil,
            route: route
        )

        context.insert(entity)
        try context.save()
    }

    func fetchRoutes() throws -> [Route] {
        let descriptor = FetchDescriptor<Route>(sortBy: [SortDescriptor(\.startedAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func deleteRoute(_ route: Route) throws {
        context.delete(route)
        try context.save()
    }
}
