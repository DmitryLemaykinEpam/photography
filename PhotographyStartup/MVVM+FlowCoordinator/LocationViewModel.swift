//
//  CustomLocationViewModel.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit
import Bond

class LocationViewModel: LocationDetailsViewModelProtocol
{
    private let locationsManager: LocationsManager
    
    let locationId: String
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var notes: String?
    var distance: Double = 0
    
    var removed = Observable<Bool>(false)

    init(locationsManager: LocationsManager, location: Location)
    {
        self.locationId = location.locationId()
        self.locationsManager = locationsManager
        self.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
        self.name = location.name
        self.notes = location.notes
    }
    
    func save()
    {
        guard let location = locationsManager.locationFor(locationId: locationId) else {
            print("Error: could not save location because locationId: \(locationId) not found")
            return
        }
        
        location.name = name
        location.notes = notes
        location.lat = coordinate.latitude
        location.lon = coordinate.longitude
        
        locationsManager.saveToPersistentStore()
        return
    }
}

extension LocationViewModel: Equatable
{
    public static func == (lhs: LocationViewModel, rhs: LocationViewModel) -> Bool
    {
        let result = lhs.locationId == rhs.locationId ? true : false
        return result
    }
}
