//
//  ContentView.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import SwiftUI
import MapKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State var viewModel: ContentViewModel
    private let repository: LocationRepository

    @State private var mapPosition: MapCameraPosition = .automatic

    init(viewModel: ContentViewModel, repository: LocationRepository) {
        self._viewModel = State(wrappedValue: viewModel)
        self.repository = repository
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                LiveMapView(
                    locations: viewModel.liveLocations,
                    mapPosition: $mapPosition
                )
                .overlay(alignment: .topTrailing) {
                    StatusBadge(
                        isActive: viewModel.isTrackingRequested,
                        title: viewModel.statusText
                    )
                    .padding(16)
                }

                Form {
                    LastLocationSection(
                        location: viewModel.lastLocation,
                        steps: viewModel.steps
                    )
                    
                    Section {
                        Picker(Labels.Labels.mode, selection: $viewModel.selectedMode) {
                            ForEach(TrackingMode.allCases) { mode in
                                Text(mode.title).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        TrackButton(viewModel: viewModel)
                    }
                    
                    if viewModel.rejectedLocationCount > 0 {
                        Section(Labels.Sections.rejectedUpdates) {
                            LabeledContent(
                                Labels.Labels.count,
                                value: viewModel.rejectedLocationCount.formatted()
                            )
                        }
                    }
                }
            }
            .navigationTitle(Labels.Navigation.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Records") {
                        TrackedLocationsDestination(repository: repository)
                    }
                }
            }
        }
        .alert(
            Labels.Alerts.permissionTitle,
            isPresented: $viewModel.showLocationPermissionAlert
        ) {
            Button(Labels.Alerts.openSettings) {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
            Button(Labels.Alerts.cancel, role: .cancel) {}
        } message: {
            Text(viewModel.statusText)
        }
        .onChange(of: scenePhase) { _, phase in
            viewModel.handleScenePhase(phase)
        }
        .onChange(of: viewModel.lastLocation) { _, newLocation in
            if let newLocation {
                withAnimation(.easeInOut) {
                    mapPosition = .camera(
                        MapCamera(
                            centerCoordinate: newLocation.coordinate,
                            distance: 600
                        )
                    )
                }
            }
        }
    }
}

private struct TrackedLocationsDestination: View {
    let repository: LocationRepository
    @State private var viewModel: TrackedLocationsViewModel

    init(repository: LocationRepository) {
        self.repository = repository
        _viewModel = State(wrappedValue: TrackedLocationsViewModel(repository: repository))
    }

    var body: some View {
        TrackedLocationsView(viewModel: viewModel)
    }
}
