//
//  ContentViewModel.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ContentViewModel {
    var selectedMode: TrackingMode = .foreground {
        didSet {
            guard isTrackingRequested, selectedMode != oldValue else { return }
            Task { await trackerService.startTracking(mode: selectedMode) }
        }
    }

    var statusText = "Not tracking"
    var lastLocation: LocationPoint?
    var rejectedLocationCount = 0
    var showLocationPermissionAlert = false
    private(set) var isTrackingRequested = false

    @ObservationIgnored private let trackerService: LocationTrackingService
    @ObservationIgnored private let repository: LocationRepository
    @ObservationIgnored private var eventTask: Task<Void, Never>?
    @ObservationIgnored private var saveTask: Task<Void, Never>?
    @ObservationIgnored private var currentRoute: Route?
    @ObservationIgnored private let stepCounter: StepCounter

    init(
        trackerService: LocationTrackingService,
        repository: LocationRepository,
        stepCounter: StepCounter
    ) {
        self.trackerService = trackerService
        self.repository = repository
        self.stepCounter = stepCounter

        observeTrackerEvents()
    }

    deinit {
        eventTask?.cancel()
        saveTask?.cancel()
    }

    func requestLocationPermission() {
        Task {
            await trackerService.requestPermission()
        }
    }

    func startTracking() {
        Task {
            do {
                let route = try await repository.createRoute()
                self.currentRoute = route
                
                stepCounter.start(from: route.startedAt)

                await trackerService.startTracking(mode: selectedMode)

            } catch {
                print("Failed to create route:", error)
            }
        }
    }

    func stopTracking() {
        Task {
            await trackerService.stopTracking()

            stepCounter.stop()

            if let route = currentRoute {
                do {
                    try await repository.updateSteps(
                        stepCounter.steps,
                        routeId: route.id
                    )
                } catch {
                    print("Failed to save steps:", error)
                }
            }

            self.currentRoute = nil
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
                    self.updateSaveTaskIfNeeded()
                    print(statusText)

                case let .requireSettings(message):
                    self.statusText = message
                    self.isTrackingRequested = false
                    self.showLocationPermissionAlert = true
                    print(statusText)


                case let .locationReceived(location):
                    self.lastLocation = location
                    print(statusText)


                case .rejectedLocation:
                    self.rejectedLocationCount += 1
                    print(statusText)

                }
            }
        }
    }

    private func updateSaveTaskIfNeeded() {
        let shouldRun = isTrackingRequested && statusText.contains("Tracking")

        if shouldRun {
            if saveTask == nil {
                saveTask = Task { [weak self] in
                    await self?.saveLoop()
                }
            }
        } else {
            saveTask?.cancel()
            saveTask = nil
        }
    }

    private func saveLoop() async {
        while !Task.isCancelled {
            if let location = lastLocation, let currentRoute {
                await persist(location, for: currentRoute)
            }
            try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)
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
