//
//  Destination.swift
//  MyTrips
//
//  Created by Jeffery Ji on 11/1/25.
//

import SwiftData
import MapKit

@Model
class Destination {
    var name: String = ""
    var latitude: Double? = 0
    var longitude: Double? = 0
    var latitudeDelta: Double? = 0
    var longitudeDelta: Double? = 0
    @Relationship(deleteRule: .cascade)
    var placemarks: [MTPlacemark]? = []
    init(name: String, latitude: Double? = nil, longitude: Double? = nil, latitudeDelta: Double? = nil, longitudeDelta: Double? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
    
    var region: MKCoordinateRegion? {
        if let latitude, let longitude, let latitudeDelta, let longitudeDelta {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
        } else {
            return nil
        }
    }
}
