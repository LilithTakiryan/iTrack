//
//  ContentViewModel.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import Foundation
import Observation
import SwiftUI
import MapKit
import Swinject

@MainActor
@Observable
final class MainViewModel {
    var selectedMode: TrackingMode = .foreground {
        didSet {
            guard isTrackingRequested, selectedMode != oldValue else { return }
            modeChangeTask?.cancel()
            modeChangeTask = Task {
                await trackerService.startTracking(mode: selectedMode)
            }
        }
    }

    var statusText = "Not tracking"
    var lastLocation: LocationPoint?
    var liveLocations: [LocationPoint] = []
    var rejectedLocationCount = 0
    var showLocationPermissionAlert = false
    private(set) var isTrackingRequested = false
    var steps: Int = 0
    private let startTrackingUseCase: StartTrackingUseCaseProtocol
    @ObservationIgnored private let trackerService: LocationTrackingService
    @ObservationIgnored private let repository: LocationRepository
    @ObservationIgnored private let stepCounter: StepCounter
    
    @ObservationIgnored private var eventTask: Task<Void, Never>?
    @ObservationIgnored private var modeChangeTask: Task<Void, Never>?
    @ObservationIgnored private var currentRoute: Route?

    @MainActor
    init(
        startTrackingUseCase: StartTrackingUseCaseProtocol,
        trackerService: LocationTrackingService,
        repository: LocationRepository,
        stepCounter: StepCounter
    ) {
        self.startTrackingUseCase = startTrackingUseCase
        self.trackerService = trackerService
        self.repository = repository
        self.stepCounter = stepCounter

        observeTrackerEvents()
    }

    deinit {
        eventTask?.cancel()
        modeChangeTask?.cancel()
    }

    func requestLocationPermission() {
        Task {
            await trackerService.requestPermission()
        }
    }

    func startTracking() {
            Task {
                do {
                    let route = try await startTrackingUseCase.execute(mode: selectedMode)
                    self.currentRoute = route
                    self.liveLocations.removeAll()
                    self.lastLocation = nil
                    self.rejectedLocationCount = 0
                    self.steps = 0
                } catch {
                    print("Failed to start route:", error)
                }
            }
        }

    func stopTracking() {
        Task {
            await trackerService.stopTracking()
            stepCounter.stop()

            guard let route = currentRoute else { return }

            do {
                try await repository.updateSteps(
                    stepCounter.steps,
                    routeId: route.id
                )
            } catch {
                print("Failed to finalize route in DB:", error)
            }

            self.currentRoute = nil
            self.isTrackingRequested = false
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
                switch event {
                case let .statusUpdated(status, isTrackingRequested):
                    self.statusText = status
                    self.isTrackingRequested = isTrackingRequested

                case let .requireSettings(message):
                    self.statusText = message
                    self.isTrackingRequested = false
                    self.showLocationPermissionAlert = true

                case let .locationReceived(location):
                    self.lastLocation = location
                    self.liveLocations.append(location)
                    
                    if let route = self.currentRoute {
                        await self.persist(location, for: route)
                    }

                case .rejectedLocation:
                    self.rejectedLocationCount += 1
                }
            }
        }
    }

    private func persist(_ location: LocationPoint, for route: Route) async {
        do {
            try await repository.addLocation(location, to: route.id)
        } catch {
            print("Failed to save location:", error)
        }
    }
}

@MainActor
extension MainViewModel {
    static func makeDefault(trackerService: LocationTrackingService, repository: LocationRepository, stepCounter: StepCounter) -> MainViewModel {
        let startTrackingUseCase = AppContainer.shared.container.resolve(StartTrackingUseCaseProtocol.self)!
        return MainViewModel(
            startTrackingUseCase: startTrackingUseCase,
            trackerService: trackerService,
            repository: repository,
            stepCounter: stepCounter
        )
    }
}

extension MainViewModel {
    
    var validLocations: [LocationPoint] {
        liveLocations
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
