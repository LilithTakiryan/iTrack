//
//  RouteMapView.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//


import SwiftUI
import MapKit

struct RouteMapView: View {

    let locations: [LocationPoint]

    @Binding var mapPosition: MapCameraPosition


    private var validLocations: [LocationPoint] {
        locations
            .filter {
                CLLocationCoordinate2DIsValid($0.coordinate)
            }
            .sorted {
                $0.timestamp < $1.timestamp
            }
    }


    var body: some View {

        Map(position: $mapPosition) {

            if let start = validLocations.first {

                Annotation(
                    "Start",
                    coordinate: start.coordinate
                ) {
                    PulsingMarker(
                        icon: "figure.walk.circle.fill",
                        color: .blue
                    )
                }
            }


            if validLocations.count > 1,
               let end = validLocations.last {

                Annotation(
                    "End",
                    coordinate: end.coordinate
                ) {
                    PulsingMarker(
                        icon: "flag.pattern.checkered.circle.fill",
                        color: .purple
                    )
                }
            }


            if validLocations.count > 1 {
                MapPolyline(
                    coordinates: validLocations.map(\.coordinate)
                )
                .stroke(
                    .blue,
                    lineWidth: 3
                )
            }
        }
        .mapStyle(.standard)
        .ignoresSafeArea()
    }
}
