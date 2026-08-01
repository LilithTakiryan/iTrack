//
//  TrackingState.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//


enum TrackingState: Equatable {
    case idle
    case tracking
    case paused
    case requestingPermission
    case requiresSettings
    case serviceError

    var isActive: Bool {
        switch self {
        case .tracking:
            return true
        case .idle, .paused, .requestingPermission, .requiresSettings, .serviceError:
            return false
        }
    }
}