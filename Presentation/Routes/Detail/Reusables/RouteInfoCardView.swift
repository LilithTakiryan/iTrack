//
//  RouteInfoCardView.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//

import SwiftUI

struct RouteInfoCardView: View {

    let startedAt: Date
    let endedAt: Date
    let locationCount: Int
    let duration: String
    let formattedDistance: String
    let steps: Int

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Route Details")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)

                        Text("\(startedAt.formatted(date: .abbreviated, time: .shortened)) – \(endedAt.formatted(date: .omitted, time: .shortened))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "map.fill")
                        .font(.footnote)
                        .foregroundStyle(.tint)
                        .padding(6)
                        .background(.tint.opacity(0.12), in: Circle())
                }

                Divider()

                HStack(alignment: .top) {
                    compactMetric(
                        icon: "clock.fill",
                        iconColor: .orange,
                        value: duration,
                        label: "Duration"
                    )

                    Spacer()

                    compactMetric(
                        icon: "shoeprints.fill",
                        iconColor: .blue,
                        value: formattedDistance,
                        label: "Distance"
                    )

                    Spacer()

                    compactMetric(
                        icon: "figure.walk",
                        iconColor: .green,
                        value: steps.formatted(.number),
                        label: "Steps"
                    )

                    Spacer()

                    compactMetric(
                        icon: "mappin.and.ellipse",
                        iconColor: .purple,
                        value: locationCount.formatted(.number),
                        label: "Pts"
                    )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private func compactMetric(
        icon: String,
        iconColor: Color,
        value: String,
        label: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(iconColor)

                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.callout.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}
