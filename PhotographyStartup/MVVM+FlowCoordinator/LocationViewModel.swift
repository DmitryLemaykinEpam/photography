//
//  CustomLocationViewModel.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit
import MagicalRecord

protocol LocationViewModelDelegate: class
{
    func locationViewModelDidChange(_ locationViewModel: LocationViewModel)
}

class LocationViewModel
{
    weak var delegate: LocationViewModelDelegate?
    var locationsManager: LocationsManager!
    
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var notes: String?
    var distance: Double = 0

    // Updated fields
    var updatedCoordinate: CLLocationCoordinate2D?
    var updatedName: String?
    var updatedNotes: String?
    
    init(locationsManager: LocationsManager, lat: CLLocationDegrees, lon: CLLocationDegrees)
    {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.locationsManager = locationsManager
    }
    
    convenience init(locationsManager: LocationsManager!, location: Location)
    {
        self.init(locationsManager: locationsManager, lat: location.lat, lon: location.lon)
        self.name = location.name
        self.notes = location.notes
    }
    
    func applyUpdates()
    {
        name = updatedName
        notes = updatedNotes
        
        guard let updatedCoordinate = updatedCoordinate else {
            return
        }
        coordinate = updatedCoordinate
    }
    
    func saveUpdates() -> String?
    {
        var location = locationsManager.locationFor(name: name, coordinate: coordinate)
        if location == nil
        {
            location = locationsManager.createLocation()
        }
        
        guard let existedLocation = location else
        {
            return "Error: could not create location for ViewModel"
        }
        
        existedLocation.name = updatedName
        existedLocation.notes = updatedNotes
        
        if let updatedCoordinate =  self.updatedCoordinate
        {
            existedLocation.lat = updatedCoordinate.latitude
            existedLocation.lon = updatedCoordinate.longitude
        }
        
        locationsManager.saveToPersistentStore()
        applyUpdates()
        
        return nil
    }
}

extension LocationViewModel: Equatable
{
    public static func == (lhs: LocationViewModel, rhs: LocationViewModel) -> Bool
    {
        if lhs.name == rhs.name &&
           lhs.coordinate == rhs.coordinate &&
           lhs.notes == rhs.notes
        {
            return true
        }
        return false
    }
}
