//
//  CustomLocationViewModel.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit

protocol LocationViewModelDelegate: class
{
    func locationViewModelDidChange(_ locationViewModel: LocationViewModel)
}

class LocationViewModel
{
    weak var delegate: LocationViewModelDelegate?
    
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var notes: String?
    var distance: String = ""

    // Updated fields
    var updatedCoordinate: CLLocationCoordinate2D?
    var updatedName: String?
    var updatedNotes: String?
    
    init(lat: CLLocationDegrees, lon: CLLocationDegrees)
    {
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        updatedCoordinate = coordinate
    }
    
    convenience init(_ location: Location)
    {
        self.init(lat: location.lat, lon: location.lon)
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
