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
    func locationAdded(_ location: Location)
    func locationUpdated(_ location: Location, oldCoordinate: CLLocationCoordinate2D, newCoordinate: CLLocationCoordinate2D)
    func locationRemoved(_ location: Location)
    func locationsReloaded()
}

class HomeViewModel
{
    var error: Error?
    var refreshing = false
    var userCoordinate = Observable<CLLocationCoordinate2D?>(nil)
    
    private let locationsManager: LocationsManager
    private let userLocationManager: UserLocationManager
    
    weak var delegate: HomeViewModelDelegate?
    
    init(locationsManager : LocationsManager, userLocationManager: UserLocationManager)
    {
        self.locationsManager = locationsManager
        self.userLocationManager = userLocationManager
        
        self.locationsManager.delegate = self
        
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
    func locationFor(_ coordinate: CLLocationCoordinate2D) -> Location?
    {
        return locationsManager.locationFor(coordinate)
    }
    
    func updateVisibleArea(neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D)
    {
        locationsManager.updateVisibleArea(neCoordinate: neCoordinate, swCoordinate: swCoordinate)
    }
    
    func createNewLocation() -> Location?
    {
        return locationsManager.createLocation()
    }
    
    func updateLocationCoordinate(_ location: Location, newCoordinate: CLLocationCoordinate2D)
    {
        let oldCoordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
        
        location.lat = newCoordinate.latitude
        location.lon = newCoordinate.longitude
        
        locationsManager.saveToPersistentStore()
        delegate?.locationUpdated(location, oldCoordinate: oldCoordinate, newCoordinate: newCoordinate)
    }
    
    func updateVisibleLocations()
    {
        locationsManager.fetch()
    }
    
    func visibleLocations() -> [Location]?
    {
        return locationsManager.visibleLocations()
    }
    
    func removeLocation(_ location: Location)
    {
        locationsManager.removeLocation(location)
        locationsManager.saveToPersistentStore()
    }
}

// MARK - LocationsManagerDelegate
extension HomeViewModel: LocationsManagerDelegate
{
    func locationAdded(_ location: Location)
    {
        self.delegate?.locationAdded(location)
    }
    
    func locationRemoved(_ location: Location)
    {
        self.delegate?.locationRemoved(location)
    }
    
    func locationUpdated(_ location: Location)
    {
        // Does nothing, need to get old and new coordinate
    }
    
    func locationsReloaded()
    {
        self.delegate?.locationsReloaded()
    }
}
