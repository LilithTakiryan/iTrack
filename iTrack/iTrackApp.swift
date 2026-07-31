//
//  iTrackApp.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import SwiftUI
import Swinject
import SwiftData

@main
struct iTrackApp: App {
    var body: some Scene {
        WindowGroup {
            MainScreen()
        }
        .modelContainer(
            AppContainer.shared.container.resolve(ModelContainer.self)!)
    }
}
