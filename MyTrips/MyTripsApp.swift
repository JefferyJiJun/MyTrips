//
//  MyTripsApp.swift
//  MyTrips
//
//  Created by Jeffery Ji on 4/1/25.
//

import SwiftUI
import SwiftData

@main
struct MyTripsApp: App {
    @State private var locationManager = LocationManager()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Destination.self, MTPlacemark.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
            //return try ModelContainer(for: schema)
        } catch {
            print("Error while creating ModelContainer: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    var body: some Scene {
        WindowGroup {
            if locationManager.isAuthorized {
                StartTab()
            } else {
                Text("Need help user!")
            }
        }
        .modelContainer(sharedModelContainer)
        .environment(locationManager)
    }
}
