//
//  ContentView.swift
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
    
    @Bindable var viewModel: MainViewModel
    @MainActor
    init(viewModel: MainViewModel? = nil) {
        if let viewModel {
            self.viewModel = viewModel
        } else {
            self.viewModel = AppContainer.shared.container.resolve(MainViewModel.self)!
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    RouteMapView(
                        locations: viewModel.liveLocations,
                        mapPosition: $mapPosition
                    )
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(alignment: .topTrailing) {
                   MapTagView(
    title: viewModel.statusText,
    icon: .statusDot(isActive: viewModel.trackingState.isActive),
    isActiveStyle: viewModel.trackingState.isActive
)
                        .padding(12)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        MapTagView(
                            title: viewModel.formattedDistance(unitRawValue: distanceUnit),
                            icon: .system("figure.walk")
                        )
                        .padding(12)
                    }
                    .listRowInsets(EdgeInsets())
                }
                
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
                } header: {
                    Text(Labels.Labels.mode)
                }
                
                Section {
                    TrackButton(viewModel: viewModel)
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                if viewModel.rejectedLocationCount > 0 {
                    Section(Labels.Sections.rejectedUpdates) {
                        LabeledContent(
                            Labels.Labels.count,
                            value: viewModel.rejectedLocationCount.formatted()
                        )
                    }
                }
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

