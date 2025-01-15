//
//  MapManager.swift
//  MyTrips
//
//  Created by Jeffery Ji on 7/1/25.
//

import MapKit
import SwiftData

enum MapManager {
    @MainActor
    static func searchPlaces(_ modelContext: ModelContext, searchText: String, visibleRegion: MKCoordinateRegion?) async {
        print("searchPlaces func ....1")
        removeSearchResults(modelContext)
        print("searchPlaces func ....2")
        let request = MKLocalSearch.Request()
        print("searchPlaces func ....3")
        request.naturalLanguageQuery = searchText
        print("searchPlaces func ....4")
        if let visibleRegion {
            request.region = visibleRegion
        }
        print("searchPlaces func ....5")
        let searchItems = try? await MKLocalSearch(request: request).start()
        print("searchPlaces func ....6")
        let results = searchItems?.mapItems ?? []
        print("searchPlaces func ....7")
        results.forEach{
            let mtPlacemark = MTPlacemark(
                name: $0.placemark.name ?? "",
                address: $0.placemark.title ?? "",
                latitude: $0.placemark.coordinate.latitude,
                longitude: $0.placemark.coordinate.longitude
            )
            print("searchPlaces func ....8")
            modelContext.insert(mtPlacemark)
            print("searchPlaces func ....9")
        }
        print("searchPlaces func ....10")
        
    }
    
    static func removeSearchResults(_ modelContext: ModelContext) {
        let searchPredicate = #Predicate<MTPlacemark> { $0.destination == nil }
        try? modelContext.delete(model: MTPlacemark.self, where: searchPredicate)
    }
    
    static func distance(meters: Double) -> String {
        let userLocale = Locale.current
        let formatter = MeasurementFormatter()
        var option: MeasurementFormatter.UnitOptions = []
        option.insert(.providedUnit)
        option.insert(.naturalScale)
        formatter.unitOptions = option
        let meterValue = Measurement(value: meters, unit: UnitLength.meters)
        let yardsValue = Measurement(value: meters, unit: UnitLength.yards)
        return formatter.string(from: userLocale.measurementSystem == .metric ? meterValue : yardsValue)
    }
}


func fetchLoookaroundPreview(selectedPlacemark: MTPlacemark) async -> MKLookAroundScene? {
    let lookaroundRequest = MKLookAroundSceneRequest(coordinate: selectedPlacemark.coordinate)
    let lookaroundScene = try? await lookaroundRequest.scene
    return lookaroundScene
}


