//
//  HomeViewModel.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/20/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import MapKit
import Bond

protocol HomeViewModelDelegate: class
{
    func locationAdded(_ locationViewModel: LocationViewModel)
    func locationUpdated(_ locationViewModel: LocationViewModel)
    func locationRemoved(_ locationViewModel: LocationViewModel)
    func locationsReloaded()
}

class HomeViewModel
{
    var error: Error?
    var refreshing = false
    var userCoordinate = Observable<CLLocationCoordinate2D?>(nil)
    
    var visibleLocationViewModels = [LocationViewModel]()
    
    private let locationsManager: LocationsManager
    private let userLocationManager: UserLocationManager
    
    weak var delegate: HomeViewModelDelegate?
    
    init(locationsManager: LocationsManager, userLocationManager: UserLocationManager)
    {
        self.locationsManager = locationsManager
        self.userLocationManager = userLocationManager
        
        self.locationsManager.delegate = self
        
        // Path trough of bindings
        self.userCoordinate = self.userLocationManager.userCoordinate
    }
    
    func startTarckingUserLoaction()
    {
        userLocationManager.startTarckingUserLoaction()
    }
 
    func stopTarckingUserLoaction()
    {
        userLocationManager.stopTarckingUserLoaction()
    }
}

// MARK - Visible locations
extension HomeViewModel
{
    func locationViewModelFor(name: String, coordinate: CLLocationCoordinate2D) -> LocationViewModel?
    {
        for locationViewModel in visibleLocationViewModels
        {
            if locationViewModel.name == name && locationViewModel.coordinate == coordinate
            {
                return locationViewModel
            }
        }

        return nil
    }
    
    func updateVisibleArea(neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D)
    {
        locationsManager.updateVisibleArea(neCoordinate: neCoordinate, swCoordinate: swCoordinate)
    }
    
    func createNewLocation(_ locationViewModel: LocationViewModel)
    {
        guard let newLocation = locationsManager.createLocation() else {
            print("Error: Could not create new location")
            return
        }
        
        newLocation.name = locationViewModel.name
        newLocation.notes = locationViewModel.notes
        newLocation.lat = locationViewModel.coordinate.latitude
        newLocation.lon = locationViewModel.coordinate.longitude
        
        locationsManager.saveToPersistentStore()
    }
    
    func updateLocationViewModel(_ locationViewModel: LocationViewModel)
    {
        guard let location = locationsManager.locationFor(name: locationViewModel.name, coordinate: locationViewModel.coordinate) else {
            print("Error: coudl not find Location for locationViewModel")
            return
        }
        
        if let updatedName = locationViewModel.updatedName {
            location.name = updatedName
        }
        
        if let updatedNotes = locationViewModel.updatedNotes {
            location.notes = updatedNotes
        }
        
        if let updatedCoordinate = locationViewModel.updatedCoordinate {
            location.lat = updatedCoordinate.latitude
            location.lon = updatedCoordinate.longitude
        }
        
        locationsManager.saveToPersistentStore()
    }
    
    func removeLocation(_ locationViewModel: LocationViewModel)
    {
        guard let location = locationsManager.locationFor(name: locationViewModel.name, coordinate: locationViewModel.coordinate) else {
            print("Error: could not get Locations for LocationsViewModel")
            return
        }
        
        locationsManager.removeLocation(location)
        locationsManager.saveToPersistentStore()
    }
}

// MARK - LocationsManagerDelegate
extension HomeViewModel: LocationsManagerDelegate
{
    func locationAdded(_ location: Location)
    {
        let locationViewModel = LocationViewModel(location)
        visibleLocationViewModels.append(locationViewModel)
        self.delegate?.locationAdded(locationViewModel)
    }
    
    func locationRemoved(_ location: Location)
    {
        let locationViewModel = LocationViewModel(location)
        visibleLocationViewModels.remove(locationViewModel)
        
        self.delegate?.locationRemoved(locationViewModel)
    }
    
    func locationUpdated(_ updatedLocation: Location, indexPath: IndexPath?)
    {
        guard let indexPath = indexPath else {
            print("Error: no index psth for update")
            return
        }
        
        let updatedLocationViewModel = visibleLocationViewModels[indexPath.row]
        updatedLocationViewModel.updatedName = updatedLocation.name
        updatedLocationViewModel.updatedNotes = updatedLocation.notes
        updatedLocationViewModel.updatedCoordinate = CLLocationCoordinate2D(latitude: updatedLocation.lat
            , longitude: updatedLocation.lon)
        
        self.delegate?.locationUpdated(updatedLocationViewModel)
    }
    
    func locationsReloaded()
    {
        visibleLocationViewModels.removeAll()
        
        guard let visibleLocations = locationsManager.visibleLocations() else {
            return
        }
        
        for location in visibleLocations
        {
            let locationViewModel = LocationViewModel(location)
            visibleLocationViewModels.append(locationViewModel)
        }
        
        self.delegate?.locationsReloaded()
    }
}
