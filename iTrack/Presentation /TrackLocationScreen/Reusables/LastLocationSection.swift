//
//  LastLocationSection.swift
//  iTrack
//
//  Created by lilit on 31.07.26.
//
import SwiftUI

#Preview("LastLocationSection") {
    LastLocationSection(
        location: sampleLocations.first,
        steps: 1234
    )
}
struct LastLocationSection: View {
    let location: LocationPoint?
    let steps: Int

    var body: some View {
        Section {
            if let location {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        MiniTelemetryCard(
                            title: Labels.Labels.steps,
                            value: steps.formatted(),
                            icon: "figure.walk",
                            color: .blue
                        )

                        MiniTelemetryCard(
                            title: Labels.Labels.accuracy,
                            value: location.accuracy.formatted(.number.precision(.fractionLength(1))) + " m",
                            icon: "location.north.line.fill",
                            color: .green
                        )

                        MiniTelemetryCard(
                            title: Labels.Labels.updated,
                            value: location.timestamp.formatted(date: .omitted, time: .shortened),
                            icon: "clock",
                            color: .orange
                        )
                    }

                    HStack {
                        Label {
                            Text("\(location.latitude, specifier: "%.5f"), \(location.longitude, specifier: "%.5f")")
                                .font(.caption.monospacedDigit())
                                .foregroundColor(.secondary)
                                .textSelection(.enabled)
                        } icon: {
                            Image(systemName: "safari")
                                .foregroundColor(.purple)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .padding(12)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                ContentUnavailableView(
                    Labels.Labels.noLocation,
                    systemImage: "location.slash",
                    description: Text("Start tracking to record telemetry")
                )
                .symbolVariant(.fill)
                .padding(.vertical, 16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
    }
}


