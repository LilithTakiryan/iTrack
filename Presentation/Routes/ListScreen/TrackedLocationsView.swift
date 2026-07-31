//
//  TrackedLocationsView.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import SwiftUI
import Swinject
struct TrackedLocationsView: View {
    @State private var viewModel: TrackedLocationsViewModel

    init(viewModel: TrackedLocationsViewModel = AppContainer.shared.container.resolve(TrackedLocationsViewModel.self)!) {
            self.viewModel = viewModel
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
                                RouteDetailScreen(route: route)
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
