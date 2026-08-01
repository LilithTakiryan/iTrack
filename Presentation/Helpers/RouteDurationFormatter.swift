//
//  RouteDurationFormatter.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//

import Foundation

enum RouteDurationFormatter {

    private static let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        return formatter
    }()

    static func format(
        startedAt: Date,
        endedAt: Date?
    ) -> String {
        let end = endedAt ?? Date()
        let interval = max(0, end.timeIntervalSince(startedAt))

        guard interval > 0 else {
            return "0m"
        }

        return formatter.string(from: interval) ?? "0m"
    }
}
