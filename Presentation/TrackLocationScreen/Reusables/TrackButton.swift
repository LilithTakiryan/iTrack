//
//  TrackButton.swift
//  iTrack
//
//  Created by lilit on 31.07.26.
//
import SwiftUI

struct TrackButton: View {
    let viewModel: TrackLocationViewModel
    
    var body: some View {
    
        Button(
                      role: viewModel.isTrackingRequested ? .destructive : nil
                  ) {
                      if viewModel.isTrackingRequested {
                          viewModel.stopTracking()
                      } else {
                          viewModel.startTracking()
                      }
                  } label: {
                      Label(
                          viewModel.isTrackingRequested ? Labels.Labels.stopTracking : Labels.Labels.startTracking,
                          systemImage: viewModel.isTrackingRequested ? "stop.fill" : "play.fill"
                      )
                      .fontWeight(.bold)
                      .foregroundStyle(.white)
                      .frame(maxWidth: .infinity)
                      .padding(.vertical, 6)
                  }
                  .buttonStyle(.borderedProminent)
                  .tint(viewModel.isTrackingRequested ? .red : .accentColor)
                  .listRowBackground(Color.clear)
                  .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }


