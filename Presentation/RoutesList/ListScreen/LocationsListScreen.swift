//
//  TrackedLocationsView.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import SwiftUI
import Swinject

struct LocationsListScreen: View {
    @State private var viewModel: LocationsListViewModel
    
    init(viewModel: LocationsListViewModel = AppContainer.shared.container.resolve(LocationsListViewModel.self)!) {
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
