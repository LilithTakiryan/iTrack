//
//  StopTrackingUseCase.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import Foundation

public struct StopTrackingUseCase: Sendable {
    private let tracker: LocationTrackingService

    public init(tracker: LocationTrackingService) {
        self.tracker = tracker
    }

    public func execute() async {
        await tracker.stopTracking()
    }
}
