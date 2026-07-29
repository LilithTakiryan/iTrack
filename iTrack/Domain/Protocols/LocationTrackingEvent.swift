//
//  LocationTrackingEvent.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//


import Foundation

public enum LocationTrackingEvent: Sendable {
    case statusUpdated(statusText: String, isTrackingRequested: Bool)
    case requireSettings(message: String)
    case locationReceived(LocationPoint)
    case rejectedLocation
}