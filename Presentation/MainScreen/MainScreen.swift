//
//  MainScreen.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//

import SwiftUI
import MapKit
import Swinject

struct MainScreen: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var mapPosition: MapCameraPosition = .automatic
    @AppStorage("distanceUnit") private var distanceUnit = DistanceUnit.metric.rawValue
    
    @State var viewModel: MainViewModel

    @MainActor
    init(viewModel: MainViewModel? = nil) {
        let resolvedViewModel = viewModel ?? AppContainer.shared.container.resolve(MainViewModel.self)!
        self._viewModel = State(wrappedValue: resolvedViewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        MapTagView(
                            title: viewModel.state.statusText,
                            icon: .statusDot(isActive: viewModel.state.trackingState.isActive),
                            isActiveStyle: viewModel.state.trackingState.isActive
                        )
                        Spacer()
                        MapTagView(
                            title: viewModel.formattedDistance(unitRawValue: distanceUnit),
                            icon: .system("figure.walk"),
                            isActiveStyle: viewModel.state.trackingState.isActive
                        )
                    }
                    
                    RouteMapView(
                        locations: viewModel.state.liveLocations,
                        mapPosition: $mapPosition
                    )
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    LastLocationSection(
                        location: viewModel.state.lastLocation,
                        steps: viewModel.state.steps
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Labels.Labels.mode)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker(Labels.Labels.mode, selection: $viewModel.state.selectedMode) {
                            ForEach(TrackingMode.allCases) { mode in
                                Text(mode.title).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: viewModel.state.selectedMode) { _, newMode in
                            viewModel.setMode(newMode)
                        }
                    }
                    
                    TrackButton(viewModel: viewModel)
                        .frame(maxWidth: .infinity)
                    
                    if viewModel.state.rejectedLocationCount > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Labels.Sections.rejectedUpdates)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            LabeledContent(
                                Labels.Labels.count,
                                value: viewModel.state.rejectedLocationCount.formatted()
                            )
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(Labels.Navigation.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Records") {
                        LocationsListScreen()
                    }
                }
            }
            .alert(
                Labels.Alerts.permissionTitle,
                isPresented: $viewModel.state.showLocationPermissionAlert
            ) {
                Button(Labels.Alerts.openSettings) {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
                Button(Labels.Alerts.cancel, role: .cancel) {}
            } message: {
                Text(viewModel.state.statusText)
            }
            .onChange(of: scenePhase) { _, phase in
                viewModel.handleScenePhase(phase)
            }
            .onChange(of: viewModel.state.lastLocation) { _, newLocation in
                guard let newLocation else { return }
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
