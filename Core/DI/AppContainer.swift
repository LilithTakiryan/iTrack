//
//  AppContainer.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//


import Foundation
import Swinject
import SwiftData

final class AppContainer {
    static let shared = AppContainer()
    let container = Container()

    private init() {
        registerDependencies()
    }

    private func registerDependencies() {
        // MARK: - SwiftData ModelContainer
        container.register(ModelContainer.self) { _ in
            do {
                return try ModelContainer(for: RouteSD.self, LocationPointSD.self)
            } catch {
                fatalError("Failed to initialize SwiftData container: \(error)")
            }
        }.inObjectScope(.container)

        // MARK: - Services & Repositories
        container.register(LocationRepository.self) { r in
            let modelContainer = r.resolve(ModelContainer.self)!
            return SwiftDataLocationRepository(modelContainer: modelContainer)
        }.inObjectScope(.container)

        container.register(LocationTrackingService.self) { _ in
            CoreLocationService()
        }.inObjectScope(.container)

        container.register(StepCounter.self) { _ in
            CoreMotionStepCounter()
        }.inObjectScope(.container)

        // MARK: - View Models
        container.register(TrackLocationViewModel.self) { r in
            TrackLocationViewModel(
                trackerService: r.resolve(LocationTrackingService.self)!,
                repository: r.resolve(LocationRepository.self)!,
                stepCounter: r.resolve(StepCounter.self)!
            )
        }
        container.register(TrackedLocationsViewModel.self) { r in
            TrackedLocationsViewModel(
                repository: r.resolve(LocationRepository.self)!
            )
        }
    }
    
}
