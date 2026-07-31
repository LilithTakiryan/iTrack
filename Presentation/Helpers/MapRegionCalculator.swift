//
//  MapRegionCalculator.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//
import MapKit


enum MapRegionCalculator {
    
    private enum Constants {
        static let singleLocationSpan = 0.01
        static let minimumSpan = 0.005
        static let mapPadding = 1.3
    }
    
    
    static func region(
        for locations: [LocationPoint]
    ) -> MKCoordinateRegion? {
        
        let coordinates = locations.map(\.coordinate)
        
        
        guard !coordinates.isEmpty else {
            return nil
        }
        
        
        if coordinates.count == 1 {
            
            return MKCoordinateRegion(
                center: coordinates[0],
                span: MKCoordinateSpan(
                    latitudeDelta: Constants.singleLocationSpan,
                    longitudeDelta: Constants.singleLocationSpan
                )
            )
        }
        
        
        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        
        
        guard
            let minLat = latitudes.min(),
            let maxLat = latitudes.max(),
            let minLon = longitudes.min(),
            let maxLon = longitudes.max()
        else {
            return nil
        }
        
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        
        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: max(
                    (maxLat - minLat) * Constants.mapPadding,
                    Constants.minimumSpan
                ),
                longitudeDelta: max(
                    (maxLon - minLon) * Constants.mapPadding,
                    Constants.minimumSpan
                )
            )
        )
    }
}
