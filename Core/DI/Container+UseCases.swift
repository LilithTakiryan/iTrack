//
//  Container+UseCases.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//

import Foundation
import Swinject

extension AppContainer {
    func registerUseCases() {
        container.register(StartTrackingUseCaseProtocol.self) { r in
            StartTrackingUseCase(
                repository: r.resolve(LocationRepository.self)!,
                trackerService: r.resolve(LocationTrackingService.self)!,
                stepCounter: r.resolve(StepCounterService.self)!
            )
        }
        
        container.register(StopTrackingUseCaseProtocol.self) { r in
            StopTrackingUseCase(
                repository: r.resolve(LocationRepository.self)!,
                trackerService: r.resolve(LocationTrackingService.self)!,
                stepCounter: r.resolve(StepCounterService.self)!
            )
        }
         
        container.register(AppendLocationUseCase.self) { r in
            AppendLocationUseCase(
                repository: r.resolve(LocationRepository.self)!
            )
        }
    }
}
