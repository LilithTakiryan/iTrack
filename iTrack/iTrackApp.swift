//
//  iTrackApp.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import SwiftUI
import SwiftData

@main
struct iTrackApp: App {
    let container: ModelContainer
    let repository: LocationRepository
    let locationService: LocationTrackingService

    init() {
        do {
            container = try ModelContainer(for: RouteSD.self, LocationPointSD.self)
            repository = SwiftDataLocationRepository(modelContainer: container)
            locationService = CoreLocationService()
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: ContentViewModel(
                    trackerService: locationService,
                    repository: repository
                ),
                repository: repository
            )
        }
        .modelContainer(container)
    }
}
