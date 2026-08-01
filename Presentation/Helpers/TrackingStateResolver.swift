//
//  TrackingStateResolver.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//


enum TrackingStateResolver {
    static func resolve(statusText: String, isTrackingRequested: Bool) -> TrackingState {
        let text = statusText.lowercased()

        if text.contains("requesting") || text.contains("starting") {
            return .requestingPermission
        }

        if text.contains("paused") {
            return .paused
        }

        if text.contains("permission required") ||
            text.contains("background permission") ||
            text.contains("location services are disabled") ||
            text.contains("location services are unavailable") {
            return .requiresSettings
        }

        if text.contains("error") || text.contains("unavailable") {
            return .serviceError
        }

        return isTrackingRequested ? .tracking : .idle
    }
}