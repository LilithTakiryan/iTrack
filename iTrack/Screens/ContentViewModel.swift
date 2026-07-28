//
//  ContentViewModel.swift
//  iTrack
//
//  Created by lilit on 28.07.26.
//

import Observation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class ContentViewModel {
    var selectedMode: TrackingMode = .foreground {
        didSet {
            guard isTrackingRequested, selectedMode != oldValue else { return }
            tracker.startTracking(mode: selectedMode)
        }
    }

    var statusText = "Not tracking"
    var lastLocation: LocationSnapshot?
    var rejectedLocationCount = 0
    var showLocationPermissionAlert = false
    private(set) var isTrackingRequested = false

    @ObservationIgnored private let tracker = LocationTracker()
    @ObservationIgnored private var eventTask: Task<Void, Never>?
    @ObservationIgnored private var modelContext: ModelContext?
    @ObservationIgnored private var saveTask: Task<Void, Never>?

    init() {
        eventTask = Task { [weak self] in
            await self?.observeTrackerEvents()
        }
    }

    deinit {
        eventTask?.cancel()
    }

    var permissionAlertMessage: String {
        tracker.permissionAlertMessage
    }

    func startTracking() {
        tracker.startTracking(mode: selectedMode)
    }

    func requestLocationPermission() {
        tracker.requestLocationPermission()
    }

    func setModelContext(_ context: ModelContext?) {
        modelContext = context
    }

    func stopTracking() {
        tracker.stopTracking()
    }

    func handleScenePhase(_ phase: ScenePhase) {
        tracker.handleScenePhase(phase)
    }

    private func observeTrackerEvents() async {
        for await event in tracker.events {
            switch event {
            case let .status(status, isTrackingRequested):
                self.statusText = status
                self.isTrackingRequested = isTrackingRequested
                updateSaveTaskIfNeeded()
            case let .requireSettings(message):
                statusText = message
                isTrackingRequested = false
                showLocationPermissionAlert = true
            case let .location(location):
                lastLocation = location
                Task { @MainActor in
                    await persist(location)
                }
            case .rejectedLocation:
                rejectedLocationCount += 1
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
        do {
            while !Task.isCancelled {
                if let location = lastLocation {
                    await persist(location)
                }
                try await Task.sleep(nanoseconds: 60 * 1_000_000_000)
            }
        } catch {
            // cancelled or interrupted
        }
    }

    private func persist(_ location: LocationSnapshot) async {
        guard let context = modelContext else { return }

        let entity = TrackedLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            timestamp: location.timestamp,
            accuracy: location.accuracy,
            altitude: nil,
            speed: nil,
            course: nil
        )

        context.insert(entity)
        do {
            try context.save()
        } catch {
            print("Failed to save location:", error)
        }
    }
}
