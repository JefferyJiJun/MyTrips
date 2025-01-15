//
//  ContentView.swift
//  MyTrips
//
//  Created by Jeffery Ji on 4/1/25.
//

import SwiftUI
import SwiftData

struct StartTab: View {
    
    var body: some View {
        TabView {
            Group {
                TripMapView()
                    .tabItem {
                        Label("TripMap", systemImage: "map")
                    }
                DestinationListView()
                    .tabItem {
                        Label("Destinations", systemImage: "globe.desk")
                    }
            }
            .toolbarBackground(.app.opacity(0.8), for: .tabBar)
            .toolbarBackgroundVisibility(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
        }
    }
        
}
