//
//  RouteDetailView.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//

import SwiftUI
import MapKit

#Preview {
    NavigationStack {
        RouteDetailView(
            route: sampleRoute
        )
    }
}

struct RouteDetailView: View {
    let route: Route
    
    @State private var mapPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            RouteMapView(
                locations: route.locations,
                mapPosition: $mapPosition
            )
            
            RouteInfoCardView(
                startedAt: route.startedAt,
                locationCount: validLocations.count,
                duration: formattedDuration
            )
        }
        .navigationTitle("Route")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            centerMapOnRoute()
        }
    }
}



// MARK: - Helpers
private extension RouteDetailView {
    
    var formattedDuration: String {
        RouteDurationFormatter.format(
            startedAt: route.startedAt,
            endedAt: route.endedAt
        )
    }
    
    var validLocations: [LocationPoint] {
        route.locations
            .filter {
                CLLocationCoordinate2DIsValid($0.coordinate)
            }
            .sorted {
                $0.timestamp < $1.timestamp
            }
    }
    
    func centerMapOnRoute() {
        
        guard let region = MapRegionCalculator.region(
            for: validLocations
        ) else {
            return
        }
        
        mapPosition = .region(region)
    }
}


// MARK: - LocationPoint Extension
extension LocationPoint {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
