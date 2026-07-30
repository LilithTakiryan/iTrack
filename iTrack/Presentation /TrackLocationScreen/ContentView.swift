//
//  ContentView.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: ContentViewModel
    private let repository: LocationRepository

    init(viewModel: ContentViewModel, repository: LocationRepository) {
        _viewModel = State(initialValue: viewModel)
        self.repository = repository
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(Labels.Sections.tracking) {
                    Picker(Labels.Labels.mode, selection: $viewModel.selectedMode) {
                        ForEach(TrackingMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    LabeledContent(Labels.Labels.status, value: viewModel.statusText)

                    if viewModel.isTrackingRequested {
                        Button(Labels.Labels.stopTracking, role: .destructive) {
                            viewModel.stopTracking()
                        }
                    } else {
                        Button(Labels.Labels.startTracking) {
                            viewModel.startTracking()
                        }
                    }
                }

                Section(Labels.Sections.lastLocation) {
                    if let location = viewModel.lastLocation {
                        LabeledContent(
                            Labels.Labels.latitude,
                            value: location.latitude.formatted(.number.precision(.fractionLength(6)))
                        )
                        LabeledContent(
                            Labels.Labels.longitude,
                            value: location.longitude.formatted(.number.precision(.fractionLength(6)))
                        )
                        LabeledContent(
                            Labels.Labels.accuracy,
                            value: String(format: Labels.Labels.metersFormat, location.accuracy.formatted(.number.precision(.fractionLength(1))))
                        )
                        LabeledContent(
                            Labels.Labels.updated,
                            value: location.timestamp.formatted(date: .omitted, time: .standard)
                        )
                        LabeledContent(
                            Labels.Labels.steps,
                                value: "\(viewModel.steps)"
                            )
                    } else {
                        Text(Labels.Labels.noLocation)
                            .foregroundStyle(.secondary)
                    }
                }

                if viewModel.rejectedLocationCount > 0 {
                    Section(Labels.Sections.rejectedUpdates) {
                        LabeledContent(Labels.Labels.count, value: "\(viewModel.rejectedLocationCount)")
                    }
                }
            }
            .navigationTitle(Labels.Navigation.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Records") {
                        TrackedLocationsView(
                            viewModel: TrackedLocationsViewModel(repository: repository)
                        )
                    }
                }
            }
        }
        .alert(Labels.Alerts.permissionTitle, isPresented: $viewModel.showLocationPermissionAlert) {
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
    }
}
