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
        
        // MARK: - Use Cases
        container.register(StartTrackingUseCaseProtocol.self) { r in
            StartTrackingUseCase(
                repository: r.resolve(LocationRepository.self)!,
                trackerService: r.resolve(LocationTrackingService.self)!,
                stepCounter: r.resolve(StepCounter.self)!
            )
        }
        container.register(StopTrackingUseCaseProtocol.self) { r in
            StopTrackingUseCase(
                repository: r.resolve(LocationRepository.self)!,
                trackerService: r.resolve(LocationTrackingService.self)!,
                stepCounter: r.resolve(StepCounter.self)!
            )
        }
        
        // MARK: - View Models
        container.register(MainViewModel.self) { r in
            MainViewModel(
                startTrackingUseCase:r.resolve(StartTrackingUseCaseProtocol.self)!,
                stopTrackingUseCase: r.resolve(StopTrackingUseCaseProtocol.self)!,
                trackerService: r.resolve(LocationTrackingService.self)!,
                repository: r.resolve(LocationRepository.self)!,
                stepCounter: r.resolve(StepCounter.self)!
            )
        }
        container.register(LocationsListViewModel.self) { r in
            LocationsListViewModel(
                repository: r.resolve(LocationRepository.self)!
            )
        }
        
    }
    
}
