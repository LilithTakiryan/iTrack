//
//  Labels.swift
//  iTrack
//
//  Created by lilit on 28.07.26.
//


import SwiftUI

// MARK: - UI Localized Strings

enum Labels {
    enum Sections {
        static let tracking = "Tracking"
        static let lastLocation = "Last Location"
        static let rejectedUpdates = "Rejected Updates"
    }

    enum Labels {
        static let mode = "Mode"
        static let status = "Status"
        static let stopTracking = "Stop Tracking"
        static let startTracking = "Start Tracking"
        static let latitude = "Latitude"
        static let longitude = "Longitude"
        static let accuracy = "Accuracy"
        static let updated = "Updated"
        static let count = "Count"
        static let noLocation = "No usable location yet"
        static let metersFormat = "%@ m"
    }

    enum Navigation {
        static let title = "iTrack"
    }

    enum Alerts {
        static let permissionTitle = "Location Permission Required"
        static let openSettings = "Open Settings"
        static let cancel = "Cancel"
    }
}
