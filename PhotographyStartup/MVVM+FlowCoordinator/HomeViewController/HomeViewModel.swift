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

class HomeViewModel
{
    var userCoordinate = Observable<CLLocationCoordinate2D?>(nil)
    var visibleLocationViewModels = MutableObservableArray<LocationViewModel>([])
    
    private let locationsManager: LocationsManager
    private let userLocationManager: UserLocationManager
    
    init(locationsManager: LocationsManager, userLocationManager: UserLocationManager)
    {
        self.locationsManager = locationsManager
        self.userLocationManager = userLocationManager
        
        self.locationsManager.delegate = self
        
        // Path trough of bindings
        self.userCoordinate = self.userLocationManager.userCoordinate
    }
}

// MARK - HomeViewModelProtocol
extension HomeViewModel: HomeViewModelProtocol
{
    func startTarckingUserLoaction()
    {
        userLocationManager.startTarckingUserLoaction()
    }
    
    func stopTarckingUserLoaction()
    {
        userLocationManager.stopTarckingUserLoaction()
    }
    
    func locationViewModelFor(name: String??, coordinate: CLLocationCoordinate2D) -> LocationViewModel?
    {
        let locationViewModel = visibleLocationViewModels.array.first{ $0.coordinate == coordinate && $0.name == name }
        return locationViewModel
    }
    
    func updateVisibleArea(neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D)
    {
        locationsManager.updateVisibleArea(neCoordinate: neCoordinate, swCoordinate: swCoordinate)
    }
    
    func createLocationViewModel() -> LocationViewModel?
    {
        guard let newLocation = locationsManager.createLocation() else {
            print("Error: could not create location for view model")
            return nil
        }
        
        let locationViewModel = LocationViewModel(locationsManager: locationsManager, location: newLocation)
        return locationViewModel
    }
    
    func removeLocation(_ locationViewModel: LocationViewModel)
    {
        guard let location = locationsManager.locationFor(locationId: locationViewModel.locationId ) else {
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
        let locationViewModel = LocationViewModel(locationsManager: locationsManager, location: location)
        visibleLocationViewModels.append(locationViewModel)
    }
    
    func locationRemoved(_ location: Location)
    {
        let locationId = location.locationId()
        
        guard let locationViewModelToRemove = visibleLocationViewModels.array.first(where: { $0.locationId == locationId }),
              let indexToRemove = visibleLocationViewModels.array.index(of: locationViewModelToRemove)
        else {
            print("Error: could not get locationViewModelToRemove for location: \(location)")
            return
        }
        
        locationViewModelToRemove.removed.value = true
        visibleLocationViewModels.remove(at: indexToRemove)
    }
    
    func locationUpdated(_ updatedLocation: Location, indexPath: IndexPath?)
    {
        guard let indexPath = indexPath else {
            print("Error: no index psth for update")
            return
        }
        
        let index = indexPath.row
        let updatedLocationViewModel = visibleLocationViewModels.array[index]
        updatedLocationViewModel.name = updatedLocation.name
        updatedLocationViewModel.notes = updatedLocation.notes
        updatedLocationViewModel.coordinate = CLLocationCoordinate2D(latitude: updatedLocation.lat
            , longitude: updatedLocation.lon)
        
        visibleLocationViewModels.batchUpdate { (array) in
            array[index] = updatedLocationViewModel
        }
    }
    
    func locationsReloaded()
    {
        guard let visibleLocations = locationsManager.visibleLocations() else {
            return
        }

        // View models added by portions, not one after another
        var locationViewModelsToShow = [LocationViewModel]()
        for location in visibleLocations
        {
            let locationViewModel = LocationViewModel(locationsManager: locationsManager, location: location)
            locationViewModelsToShow.append(locationViewModel)
        }
        
        // Working not as expected
        //visibleLocationViewModels2.replace(with: locationViewModelsToShow, performDiff: true)
        
        var locationViewModelsToRemove = [LocationViewModel]()
        for locationViewModel in visibleLocationViewModels.array
        {
            if !locationViewModelsToShow.contains(locationViewModel)
            {
                locationViewModelsToRemove.append(locationViewModel)
            }
        }
        
        var locationViewModelsToAdd = [LocationViewModel]()
        for locationViewModel in locationViewModelsToShow
        {
            if !visibleLocationViewModels.array.contains(locationViewModel)
            {
                locationViewModelsToAdd.append(locationViewModel)
            }
        }

        for locationViewModelToRemove in locationViewModelsToRemove
        {
            if let index = visibleLocationViewModels.array.index(of: locationViewModelToRemove)
            {
                visibleLocationViewModels.remove(at: index)
            }
        }
        
        if locationViewModelsToAdd.count > 0
        {
            visibleLocationViewModels.insert(contentsOf: locationViewModelsToAdd, at: 0)
        }
    }
}
