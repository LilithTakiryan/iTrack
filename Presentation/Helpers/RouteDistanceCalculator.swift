//
//  RouteDistanceCalculator.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//


import CoreLocation

enum DistanceUnit: String, CaseIterable {
    case metric
    case imperial
    
    var title: String {
        switch self {
        case .metric:
            return "Metric"
        case .imperial:
            return "Imperial"
        }
    }
}

enum RouteDistanceCalculator {
    
    static func distance(
        for locations: [LocationPoint]
    ) -> CLLocationDistance {
        
        let sortedLocations = locations.sorted {
            $0.timestamp < $1.timestamp
        }
        
        guard sortedLocations.count > 1 else {
            return 0
        }
        
        var totalDistance: CLLocationDistance = 0
        
        for index in 1..<sortedLocations.count {
            let previous = sortedLocations[index - 1]
            let current = sortedLocations[index]
            
            totalDistance += CLLocation(
                latitude: previous.latitude,
                longitude: previous.longitude
            )
            .distance(
                from: CLLocation(
                    latitude: current.latitude,
                    longitude: current.longitude
                )
            )
        }
        
        return totalDistance
    }
    
    
    static func formattedDistance(
        for locations: [LocationPoint],
        unit: DistanceUnit
    ) -> String {
        
        let meters = distance(for: locations)
        
        switch unit {
        case .metric:
            if meters >= 1000 {
                return String(format: "%.2f km", meters / 1000)
            }
            return "\(Int(meters)) m"
            
        case .imperial:
            let feet = meters * 3.28084
            
            if feet >= 5280 {
                return String(format: "%.2f mi", feet / 5280)
            }
            return "\(Int(feet)) ft"
        }
    }
}
