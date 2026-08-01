//
//  LocationTrackingMessage.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//


public enum LocationTrackingMessage: String, Error {
    case starting = "Starting"
    case requestingPermission = "Requesting permission"
    case permissionGranted = "Location permission already granted"
    case permissionRequired = "Location access is required to track your route. Open Settings to allow it."
    case backgroundPermissionRequired = "Background tracking needs Always permission. Open Settings to enable it."
    case requestingBackgroundPermission = "Requesting background permission"
    case notTracking = "Not tracking"
    case pausedInBackground = "Tracking paused while the app is in the background"
    case trackingInBackground = "Tracking in background"
    case tracking = "Tracking"
    case serviceUnavailable = "Location services are unavailable right now. Please try again."
    case serviceDisabled = "Location services are disabled. Enable them in Settings to continue tracking."
    case noRouteFound = "No route found"

    public var rawValue: String {
        switch self {
        case .starting: return "Starting"
        case .requestingPermission: return "Requesting permission"
        case .permissionGranted: return "Location permission already granted"
        case .permissionRequired: return "Location access is required to track your route. Open Settings to allow it."
        case .backgroundPermissionRequired: return "Background tracking needs Always permission. Open Settings to enable it."
        case .requestingBackgroundPermission: return "Requesting background permission"
        case .notTracking: return "Not tracking"
        case .pausedInBackground: return "Tracking paused while the app is in the background"
        case .trackingInBackground: return "Tracking in background"
        case .tracking: return "Tracking"
        case .serviceUnavailable: return "Location services are unavailable right now. Please try again."
        case .serviceDisabled: return "Location services are disabled. Enable them in Settings to continue tracking."
        case .noRouteFound: return "No route found"
        }
    }
}