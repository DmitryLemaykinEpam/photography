//
//  AllLocationsViewModel.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/21/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import MapKit
import Bond

class AllLocationsViewModel
{
    var locationViewModels = Observable<[LocationViewModel]>([])
    var userCoordinate = Observable<CLLocationCoordinate2D?>(nil)
    
    private let locationsManager: LocationsManager
    private let userLocationManager: UserLocationManager
    
    init(locationsManager: LocationsManager, userLocationManager: UserLocationManager)
    {
        self.locationsManager = locationsManager
        self.userLocationManager = userLocationManager
        
        self.userCoordinate = self.userLocationManager.userCoordinate
    }
    
    func fetch()
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            guard let allLocations = Location.mr_findAll() as? [Location] else {
                self.locationViewModels.value.removeAll()
                return
            }
            
            var viewModels = [LocationViewModel]()
            for location in allLocations
            {
                let locationViewModel = LocationViewModel()
                locationViewModel.name = location.name
                locationViewModel.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
                locationViewModel.notes = location.notes
                
                viewModels.append(locationViewModel)
            }
            
            guard let userCoordinate = self.userLocationManager.userCoordinate.value else {
                return
            }
            
            let distanceFormatter = MKDistanceFormatter()
            let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.latitude)
            for viewModel in viewModels
            {
                guard let coordinate = viewModel.coordinate else
                {
                    continue
                }
                
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let distance = location.distance(from: userLocation)
                
                let distanceString = distanceFormatter.string(fromDistance: distance)
                viewModel.distance = distanceString
            }
            
            viewModels.sort(by: { (viewModel1, viewModel2) -> Bool in
                if viewModel1.distance < viewModel2.distance {
                    return true
                } else {
                    return false
                }
            })
            
            self.locationViewModels.value = viewModels
        }
    }
}

// MARK - User coordinate
extension AllLocationsViewModel
{
    func startTrackingUserLoaction()
    {
        userLocationManager.startTarckingUserLoaction()
    }
    
    func stopTrackingUserLoaction()
    {
        userLocationManager.stopTarckingUserLoaction()
    }
}
