//
//  LocationTrackingService.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//


public protocol LocationTrackingService: Sendable {
    var events: AsyncStream<LocationTrackingEvent> { get }
    func startTracking(mode: TrackingMode) async
    func stopTracking() async
    func requestPermission() async
    func handleScenePhase(isBackground: Bool) async
}