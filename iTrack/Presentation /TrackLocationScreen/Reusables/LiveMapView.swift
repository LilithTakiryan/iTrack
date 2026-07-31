//
//  LiveMapView.swift
//  iTrack
//
//  Created by lilit on 31.07.26.
//


import SwiftUI
import MapKit

struct LiveMapView: View {
    let locations: [LocationPoint]
    @Binding var mapPosition: MapCameraPosition

    var body: some View {
        RouteMapView(
            locations: locations,
            mapPosition: $mapPosition
        )
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding([.horizontal, .top])
    }
}

#Preview("LiveMapView") {
    @Previewable @State var position: MapCameraPosition = .automatic
    LiveMapView(
        locations: sampleLocations,
        mapPosition: $position
    )
}



