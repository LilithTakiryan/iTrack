//
//  MainViewModel.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//

import Foundation
import Observation
import SwiftUI
import MapKit
import Swinject

@Observable
@MainActor
final class MainViewModel {
    var state: TrackingViewState
    
    private let startTrackingUseCase: StartTrackingUseCaseProtocol
    private let stopTrackingUseCase: StopTrackingUseCaseProtocol
    private let appendLocationUseCase: AppendLocationUseCaseProtocol
    
    @ObservationIgnored private let trackerService: LocationTrackingService
    @ObservationIgnored private let stepCounter: StepCounterService
    
    @ObservationIgnored private var eventTask: Task<Void, Never>?
    @ObservationIgnored private var modeChangeTask: Task<Void, Never>?
    @ObservationIgnored private var currentRoute: Route?
    
    @MainActor
    init(
        state: TrackingViewState,
        startTrackingUseCase: StartTrackingUseCaseProtocol,
        stopTrackingUseCase: StopTrackingUseCaseProtocol,
        appendLocationUseCase: AppendLocationUseCaseProtocol,
        trackerService: LocationTrackingService,
        stepCounter: StepCounterService
    ) {
        self.state = state
        self.startTrackingUseCase = startTrackingUseCase
        self.stopTrackingUseCase = stopTrackingUseCase
        self.appendLocationUseCase = appendLocationUseCase
        self.trackerService = trackerService
        self.stepCounter = stepCounter
        
        observeTrackerEvents()
    }
    
    deinit {
        eventTask?.cancel()
        modeChangeTask?.cancel()
    }
    
    
    func setMode(_ mode: TrackingMode) {
        guard state.isTrackingRequested, mode != state.selectedMode else {
            state.selectedMode = mode
            return
        }
        
        state.selectedMode = mode
        modeChangeTask?.cancel()
        modeChangeTask = Task {
            await trackerService.startTracking(mode: mode)
        }
    }
    
    func requestLocationPermission() {
        Task {
            await trackerService.requestPermission()
        }
    }
    
    func startTracking() {
        Task {
            do {
                let route = try await startTrackingUseCase.execute(mode: state.selectedMode)
                self.currentRoute = route
                self.state.reset()
            } catch {
                print("Failed to start route:", error)
            }
        }
    }
    
    func stopTracking() {
        Task {
            guard let route = currentRoute else { return }
            
            do {
                let finalSteps = try await stopTrackingUseCase.execute(routeId: route.id)
                self.state.steps = finalSteps
            } catch {
                self.state.statusText = error.localizedDescription
                self.state.lastErrorMessage = error.localizedDescription
                self.state.trackingState = .serviceError
                self.state.isTrackingRequested = false
            }
            
            self.currentRoute = nil
            self.state.isTrackingRequested = false
        }
    }
    
    func handleScenePhase(_ phase: ScenePhase) {
        Task {
            await trackerService.handleScenePhase(isBackground: phase == .background)
        }
    }
    
    
    private func observeTrackerEvents() {
        eventTask = Task { [weak self] in
            guard let self else { return }
            for await event in trackerService.events {
                let result = TrackingEventReducer.reduce(event)
                self.applyReducerResult(result)
            }
        }
    }
    
    private func applyReducerResult(_ result: TrackingEventReducer.Result) {
        if let status = result.statusText { state.statusText = status }
        if let requested = result.isTrackingRequested { state.isTrackingRequested = requested }
        if let alert = result.showLocationPermissionAlert { state.showLocationPermissionAlert = alert }
        if let errorMsg = result.lastErrorMessage { state.lastErrorMessage = errorMsg }
        if let trackingState = result.trackingState { state.trackingState = trackingState }
        if let location = result.lastLocation { state.lastLocation = location }
        
        if let newLocation = result.newLocationToAppend {
            state.liveLocations.append(newLocation)
            if let route = currentRoute {
                Task { await self.persist(newLocation, for: route) }
            }
        }
        
        if result.didRejectLocation {
            state.rejectedLocationCount += 1
        }
    }
    
    private func persist(_ location: LocationPoint, for route: Route) async {
        do {
            try await appendLocationUseCase.execute(location, for: route.id)
        } catch {
            print("Failed to save location:", error)
        }
    }
}


@MainActor
extension MainViewModel {
    static func makeDefault(
        trackerService: LocationTrackingService,
        repository: LocationRepository,
        stepCounter: StepCounterService
    ) -> MainViewModel {
        let startTrackingUseCase = AppContainer.shared.container.resolve(StartTrackingUseCaseProtocol.self)!
        let stopTrackingUseCase = AppContainer.shared.container.resolve(StopTrackingUseCaseProtocol.self)!
        let appendLocationUseCase = AppContainer.shared.container.resolve(AppendLocationUseCaseProtocol.self)!
        return MainViewModel(
            state: TrackingViewState(),
            startTrackingUseCase: startTrackingUseCase,
            stopTrackingUseCase: stopTrackingUseCase,
            appendLocationUseCase: appendLocationUseCase,
            trackerService: trackerService,
            stepCounter: stepCounter
        )
    }
}

extension MainViewModel {
    var validLocations: [LocationPoint] {
        state.liveLocations
            .filter { CLLocationCoordinate2DIsValid($0.coordinate) }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    func formattedDistance(unitRawValue: String) -> String {
        let unit = DistanceUnit(rawValue: unitRawValue) ?? .metric
        return RouteDistanceCalculator.formattedDistance(
            for: validLocations,
            unit: unit
        )
    }
}
