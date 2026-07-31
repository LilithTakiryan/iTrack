//
//  RouteDurationFormatter.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//

import Foundation


enum RouteDurationFormatter {

    static func format(
        startedAt: Date,
        endedAt: Date?
    ) -> String {

        let end = endedAt ?? Date()

        let interval = end.timeIntervalSince(startedAt)

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60


        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }
}
