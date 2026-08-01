//
//  RouteRowView.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//

import SwiftUI

struct RouteRowView: View {
    let route: Route

    private var duration: String? {
        let formatted = RouteDurationFormatter.format(
            startedAt: route.startedAt,
            endedAt: route.endedAt
        )
        return formatted == "0m" ? nil : formatted
    }

    private var timeRange: String {
        "\(route.startedAt.formatted(date: .omitted, time: .shortened)) – \(route.endedAt.formatted(date: .omitted, time: .shortened))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(route.startedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)

                Text(timeRange)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 14) {
                if let duration {
                    MetricBadgeView(icon: "clock.fill", value: duration)
                }

                if route.steps > 0 {
                    MetricBadgeView(
                        icon: "figure.walk",
                        value: "\(route.steps.formatted()) steps"
                    )
                }

                MetricBadgeView(
                    icon: "mappin.and.ellipse",
                    value: "\(route.locations.count.formatted()) pts"
                )
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
}

private struct MetricBadgeView: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.tint)

            Text(value)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}
