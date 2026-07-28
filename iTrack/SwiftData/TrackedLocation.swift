import Foundation
import SwiftData

@Model
final class TrackedLocation {
    var id: UUID = UUID()
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var accuracy: Double?
    var altitude: Double?
    var speed: Double?
    var course: Double?

    init(latitude: Double,
         longitude: Double,
         timestamp: Date,
         accuracy: Double? = nil,
         altitude: Double? = nil,
         speed: Double? = nil,
         course: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.accuracy = accuracy
        self.altitude = altitude
        self.speed = speed
        self.course = course
    }
}
