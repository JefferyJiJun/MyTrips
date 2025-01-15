//
//  DestinationListView.swift
//  MyTrips
//
//  Created by Jeffery Ji on 6/1/25.
//

import SwiftUI
import SwiftData

struct DestinationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Destination.name) private var destinations: [Destination]
    @State private var newDestination = false
    @State private var destinationName = ""
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if !destinations.isEmpty {
                    List(destinations) { destination in
                        NavigationLink(value: destination) {
                            HStack {
                                Image(systemName: "globe")
                                    .imageScale(.large)
                                //.foregroundStyle(.accent)
                                VStack {
                                    Text(destination.name)
                                    Text("^[\(destination.placemarks?.count) location](inflection: true)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    modelContext.delete(destination)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        
                    }
                    .navigationDestination(for: Destination.self) {destination in
                        //print("....destination name = \(destination.name)")
                        DestinationLocationsMapView(destination: destination)
                    }
                } else {
                    ContentUnavailableView("No Destinations",
                                       systemImage: "globe.desk",
                                       description: Text("You have not set up any destination yet! Tap on the \(Image(systemName: "plus.circle.fill")) button in the toolbar to begin.")
                    )
                }
            }
            .navigationTitle("My Destinations")
            .toolbar {
                Button {
                    newDestination.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .alert("Enter Destination Name", isPresented: $newDestination) {
                    TextField("Enter destination name", text: $destinationName)
                        .autocorrectionDisabled()
                    Button("Ok") {
                        if !destinationName.isEmpty {
                            let thisDestination = Destination(name: destinationName.trimmingCharacters(in: .whitespacesAndNewlines))
                            modelContext.insert(thisDestination)
                            destinationName = ""
                            path.append(thisDestination)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                     Text("Create a new destination")
                }
            }
        }
    }
}
