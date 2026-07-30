//
//  RouteInfoCardView.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//

import SwiftUI

struct RouteInfoCardView: View {

    let startedAt: Date
    let locationCount: Int
    let duration: String
    let formattedDistance: String
    let steps: Int


    var body: some View {

        VStack {

            Spacer()

            VStack(
                alignment: .leading,
                spacing: 12
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("Route Details")
                        .font(.headline)

                    Text(
                        startedAt.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Divider()

                HStack(spacing: 16) {

                    infoColumn(
                        title: "Total Locations",
                        value: "\(locationCount)"
                    )

                    Divider()
                        .frame(height: 40)

                    infoColumn(
                        title: "Duration",
                        value: duration
                    )
                    Spacer()
                    
                    infoColumn(
                        title: "Steps",
                        value: String(steps)
                    )

                    Spacer()
                    
                    infoColumn(
                        title: "Distance",
                        value: formattedDistance
                    )
                }
            }
            .padding(16)
            .background(.background)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
            )
            .padding(12)
        }
    }

    @ViewBuilder
    private func infoColumn(
        title: String,
        value: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
        }
    }
}
