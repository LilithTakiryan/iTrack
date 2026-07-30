//
//  LocationTrackingMessage.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//


public enum LocationTrackingMessage: String {
    case starting = "Starting"
    case requestingPermission = "Requesting permission"
    case permissionGranted = "Location permission already granted"
    case permissionRequired = "Location permission required"
    case backgroundPermissionRequired = "Background permission required"
    case requestingBackgroundPermission = "Requesting background permission"
    case notTracking = "Not tracking"
    case pausedInBackground = "Paused in background"
    case trackingInBackground = "Tracking in background"
    case tracking = "Tracking"
    
    public var rawValue: String {
        switch self {
        case .starting: return "Starting"
        case .requestingPermission: return "Requesting permission"
        case .permissionGranted: return "Location permission already granted"
        case .permissionRequired: return "Location permission required"
        case .backgroundPermissionRequired: return "Background permission required"
        case .requestingBackgroundPermission: return "Requesting background permission"
        case .notTracking: return "Not tracking"
        case .pausedInBackground: return "Paused in background"
        case .trackingInBackground: return "Tracking in background"
        case .tracking: return "Tracking"
        }
    }
}