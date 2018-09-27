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
    func locationViewModelFor(name: String??, coordinate: CLLocationCoordinate2D) -> LocationViewModel?
    {
        for locationViewModel in visibleLocationViewModels.array
        {
            if locationViewModel.coordinate == coordinate
            {
                if locationViewModel.name == nil && name == nil
                {
                    return locationViewModel
                }
                else if locationViewModel.name == name
                {
                    return locationViewModel
                }  
            }
        }

        return nil
    }
    
    func updateVisibleArea(neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D)
    {
        locationsManager.updateVisibleArea(neCoordinate: neCoordinate, swCoordinate: swCoordinate)
    }
    
    func createNewLocationViewModel() -> LocationViewModel
    {
        let locationViewModel = LocationViewModel(locationsManager: locationsManager, lat: 0, lon: 0)
        return locationViewModel
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
        let locationViewModel = LocationViewModel(locationsManager: locationsManager, location: location)
        visibleLocationViewModels.append(locationViewModel)
    }
    
    func locationRemoved(_ location: Location)
    {
        var locationViewModelIndex: Int?
        for index in 0..<visibleLocationViewModels.array.count
        {
            let locationViewModel = visibleLocationViewModels.array[index]
            
            if locationViewModel.name == location.name &&
               locationViewModel.coordinate.latitude == location.lat &&
               locationViewModel.coordinate.longitude == location.lon &&
               locationViewModel.notes == location.notes
            {
                locationViewModelIndex = index
                break
            }
        }
        
        guard let indexToRemove = locationViewModelIndex else {
            return
        }
        
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
        updatedLocationViewModel.updatedName = updatedLocation.name
        updatedLocationViewModel.updatedNotes = updatedLocation.notes
        updatedLocationViewModel.updatedCoordinate = CLLocationCoordinate2D(latitude: updatedLocation.lat
            , longitude: updatedLocation.lon)
        
        visibleLocationViewModels.batchUpdate { (array) in
            array[index] = updatedLocationViewModel
        }
        
        updatedLocationViewModel.applyUpdates()
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
