//
//  TripMapView.swift
//  MyTrips
//
//  Created by Jeffery Ji on 4/1/25.
//

import SwiftUI
import MapKit
import SwiftData

struct TripMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocationManager.self) var locationManager
    @State private var visibleRegion: MKCoordinateRegion?
    //let manager = CLLocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @Query(filter: #Predicate<MTPlacemark> {$0.destination == nil}) private var searchPlacemarks: [MTPlacemark]
    @Query private var listPlacemarks: [MTPlacemark]
    @State private var searchText = ""
    @FocusState private var searchFieldFocus: Bool
    @State private var selectedPlacemark: MTPlacemark?
    
    // Route
    @State private var showRoute = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State private var travelInterval: TimeInterval = TimeInterval(0)
    @State private var transportType: MKDirectionsTransportType = .automobile
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedPlacemark) {
            UserAnnotation()
            if !showRoute {
                ForEach(listPlacemarks) { placemark in
                    
                    Group {
                        Marker(coordinate: placemark.coordinate) {
                            Label(placemark.name, systemImage: "star")
                        }
                        .tint(.yellow)
                    }.tag(placemark)
                }
            } else {
                if let routeDestination {
                    Marker(item: routeDestination)
                        .tint(.green)
                    
                }
            }
            if let route, routeDisplaying {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }
        }
        .sheet(item: $selectedPlacemark) { selectedPlacemark in
            //LocationDetailView(selectedPlacemark: selectedPlacemark, showRoute: $showRoute, travelInterval: $travelInterval, transportType: $transportType, lookaroundScene: nil)
            //    .presentationDetents([.height(450)])
            LocationDetailView(selectedPlacemark: selectedPlacemark,
                               showRoute: $showRoute,
                               travelInterval: $travelInterval,
                               transportType: $transportType
            )
                .presentationDetents([.height(450)])
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
        .onAppear {
            updateCameraPosition()
        }
        .mapControls {
            MapUserLocationButton()
        }
        .task(id: selectedPlacemark) {
            if selectedPlacemark != nil {
                routeDisplaying = false
                showRoute = false
                route = nil
                await fetchRoute()
            }
        }
        .onChange(of: showRoute) {
            selectedPlacemark = nil
            if showRoute {
                withAnimation {
                    routeDisplaying = true
                    if let rect = route?.polyline.boundingMapRect {
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                TextField("Search...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($searchFieldFocus)
                    .overlay(alignment: .trailing) {
                        if searchFieldFocus {
                            Button {
                                searchText = ""
                                searchFieldFocus = false
                            } label: {
                                Image(systemName: "xmark.circle,fill")
                            }
                            .offset(x: -5)
                        }
                    }
                    .onSubmit {
                        Task {
                            await MapManager.searchPlaces(
                                modelContext,
                                searchText: searchText,
                                visibleRegion: visibleRegion
                            )
                            searchText = ""
                            cameraPosition = .automatic
                        }
                    }
                if routeDisplaying {
                    Button("Clear Route", systemImage: "xmark.circle") {
                        removeRoute()
                    }.buttonStyle(.borderedProminent)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .padding()
            if !searchPlacemarks.isEmpty {
                Button {
                    MapManager.removeSearchResults(modelContext)
                } label: {
                    Image(systemName: "mappin.slash.circle.fill")
                        .imageScale(.large)
                }
                .foregroundStyle(.white)
                .padding(8)
                .background(.red)
                .clipShape(.circle)
            }
            
        }
    }
    
    func updateCameraPosition() {
        if let userLocation = locationManager.userLocation {
            let userRegion = MKCoordinateRegion(center: userLocation.coordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15))
            withAnimation {
                cameraPosition = .region(userRegion)
            }
        }
    }
    
    func fetchRoute() async {
        if let userLocation = locationManager.userLocation, let selectedPlacemark {
            let request = MKDirections.Request()
            let sourcePlacemark = MKPlacemark(coordinate: userLocation.coordinate)
            let routeSource = MKMapItem(placemark: sourcePlacemark)
            let destinationPlacemark = MKPlacemark(coordinate: selectedPlacemark.coordinate)
            let routeDestination = MKMapItem(placemark: destinationPlacemark)
            routeDestination.name = selectedPlacemark.name
            request.source = routeSource
            request.destination = routeDestination
            request.transportType = transportType
            let directions = MKDirections(request: request)
            let result = try? await directions.calculate()
            route = result?.routes.first
            travelInterval = route?.expectedTravelTime ?? TimeInterval(0)
        }
    }
    
    func removeRoute() {
        routeDisplaying = false
        showRoute = false
        route = nil
        selectedPlacemark = nil
        updateCameraPosition()
    }
}

