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
//        Section {
            if let location {
                HStack(spacing: 12) {
                    MetricCardView(
                        title: Labels.Labels.steps,
                        value: "\(steps)",
                        icon: "figure.walk",
                        color: .blue
                    )

                    MetricCardView(
                        title: Labels.Labels.accuracy,
                        value: String(
                            format: Labels.Labels.metersFormat,
                            location.accuracy.formatted(.number.precision(.fractionLength(1)))
                        ),
                        icon: "location.north.line.fill",
                        color: .green
                    )
                    
                    MetricCardView(
                        title: Labels.Labels.updated,
                        value: location.timestamp.formatted(date: .omitted, time: .standard
                        ),
                        icon: "clock",
                        color: .gray
                    )
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)

                CoordinateRow(
                    title: Labels.Labels.latitude,
                    value: location.latitude,
                    systemImage: "safari"
                )

                CoordinateRow(
                    title: Labels.Labels.longitude,
                    value: location.longitude,
                    systemImage: "safari.fill"
                )
            } else {
                ContentUnavailableView(
                    Labels.Labels.noLocation,
                    systemImage: "location.slash",
                    description: Text("Start tracking to record telemetry")
                )
                .symbolVariant(.fill)
            }
        
    }
}




