//
//  MTPlacemark.swift
//  MyTrips
//
//  Created by Jeffery Ji on 6/1/25.
//

import SwiftData
import MapKit

@Model
class MTPlacemark {
    var name: String = ""
    var address: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var destination: Destination?
    
    init(name: String, address: String, latitude: Double, longitude: Double) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.destination = nil
    }
    
    init() {
        self.name = ""
        self.address = ""
        self.latitude = 0
        self.longitude = 0
        self.destination = nil
    }
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}
