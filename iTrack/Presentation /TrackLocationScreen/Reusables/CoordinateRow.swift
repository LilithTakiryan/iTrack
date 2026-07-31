//
//  CoordinateRow.swift
//  iTrack
//
//  Created by lilit on 31.07.26.
//
import SwiftUI


struct CoordinateRow: View {
    let title: String
    let value: Double
    let systemImage: String

    var body: some View {
        LabeledContent {
            Text(value.formatted(.number.precision(.fractionLength(6))))
                .font(.callout.monospacedDigit())
        } label: {
            Label(title, systemImage: systemImage)
                .foregroundStyle(.secondary)
        }
    }
}
