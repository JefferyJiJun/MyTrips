//
//  DestinationLocationsMapView.swift
//  MyTrips
//
//  Created by Jeffery Ji on 4/1/25.
//

import SwiftUI
import MapKit

struct DestinationLocationsMapView: View {
    @State private var cameraPosition: MapCameraPosition = .automatic
    var body: some View {
        Map(position: $cameraPosition)
            .onAppear {
                let paris = CLLocationCoordinate2D(latitude: 48.856788, longitude: 2.351077)
                let parisSpan = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                let parisRegion = MKCoordinateRegion(center: paris, span: parisSpan)
                cameraPosition = .region(parisRegion)
            }
    }
}

#Preview {
    DestinationLocationsMapView()
}
