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
        RouteDetailScreen(
            route: sampleRoute
        )
    }
}

struct RouteDetailScreen: View {
    let route: Route
    
    @State private var mapPosition: MapCameraPosition = .automatic
    
    @AppStorage("distanceUnit") private var distanceUnit = DistanceUnit.metric.rawValue

    var formattedDistance: String {
        RouteDistanceCalculator.formattedDistance(
            for: validLocations,
            unit: DistanceUnit(rawValue: distanceUnit) ?? .metric
        )
    }
    
    var body: some View {
        ZStack {
            RouteMapView(
                locations: route.locations,
                mapPosition: $mapPosition
            )
            
            RouteInfoCardView(
                startedAt: route.startedAt,
                endedAt: route.endedAt,
                locationCount: validLocations.count,
                duration: formattedDuration,
                formattedDistance: formattedDistance,
                steps: route.steps
            )
        }
        .navigationTitle("Route")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                ForEach(DistanceUnit.allCases, id: \.self) { unit in
                    Button(unit.title) {
                        distanceUnit = unit.rawValue
                    }
                }
            } label: {
                Image(systemName: "ruler")
            }
        }
        .onAppear {
            centerMapOnRoute()
        }
    }
}



// MARK: - Helpers
private extension RouteDetailScreen {
    
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
