//
//  Container+ViewModels.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//

import Foundation
import Swinject

extension AppContainer {
    func registerViewModels() {
        container.register(TrackingViewState.self) { _ in
            TrackingViewState()
        }
        container.register(MainViewModel.self) { r in
            MainViewModel(
                state: r.resolve(TrackingViewState.self)!,
                startTrackingUseCase: r.resolve(StartTrackingUseCaseProtocol.self)!,
                stopTrackingUseCase: r.resolve(StopTrackingUseCaseProtocol.self)!,
                appendLocationUseCase: r.resolve(AppendLocationUseCase.self)!,
                trackerService: r.resolve(LocationTrackingService.self)!,
                stepCounter: r.resolve(StepCounterService.self)!
            )
        }
        
        container.register(LocationsListViewModel.self) { r in
            LocationsListViewModel(
                repository: r.resolve(LocationRepository.self)!
            )
        }
    }
}
