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
        Group {
            if viewModel.routes.isEmpty {
                EmptyListView()
            } else {
                NavigationStack {
                    List {
                        ForEach(viewModel.routes) { route in
                            NavigationLink {
                                RouteDetailScreen(route: route) //TODO: uncomment
//                                RouteDetailScreen(route: sampleRoute)
                            } label: {
                                RouteRowView(route: route)
                            }
                        }
                        .onDelete(perform: viewModel.delete)
                    }
                    .navigationTitle("Routes")
                }
            }
        }
        .task {
            await viewModel.fetchRoutes()
        }
    }
}
