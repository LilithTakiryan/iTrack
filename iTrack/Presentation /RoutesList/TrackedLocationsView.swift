//
//  TrackedLocationsView.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import SwiftUI

struct TrackedLocationsView: View {
    @State private var viewModel: TrackedLocationsViewModel

    init(viewModel: TrackedLocationsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(viewModel.routes) { route in
                VStack(alignment: .leading, spacing: 6) {
                    Text(route.startedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)

                    Text("\(route.locations.count) locations")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let first = route.locations.min(by: { $0.timestamp < $1.timestamp }),
                       let last = route.locations.max(by: { $0.timestamp < $1.timestamp }) {
                        Text("\(first.timestamp.formatted(date: .omitted, time: .shortened)) - \(last.timestamp.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            .onDelete(perform: viewModel.delete)
        }
        .task {
            await viewModel.fetchRoutes()
        }
        .navigationTitle("Routes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }
}
