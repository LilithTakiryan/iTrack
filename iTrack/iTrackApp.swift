//
//  iTrackApp.swift
//  iTrack
//
//  Created by lilit on 28.07.26.
//

import SwiftUI
import SwiftData

@main
struct iTrackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Route.self, TrackedLocation.self])
    }
}
