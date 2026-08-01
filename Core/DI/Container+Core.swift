//
//  Container+Core.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//


import Foundation
import Swinject
import SwiftData

extension AppContainer {
    func registerCoreDataDependencies() {
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
         
        container.register(StepCounterService.self) { _ in
            CoreMotionStepCounter()
        }.inObjectScope(.container)
    }
}
