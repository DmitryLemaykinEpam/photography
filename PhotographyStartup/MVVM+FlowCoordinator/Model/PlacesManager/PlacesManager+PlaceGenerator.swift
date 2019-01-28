//
//  PlacesManager+PlaceGenerator.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 1/22/19.
//  Copyright © 2019 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import MapKit

import RxSwift
import RxCocoa

class PlaceGenereator
{
    private let disposeBug = DisposeBag()
    private var userLocation: CLLocationCoordinate2D?
    
    private let placesManager: PlacesManager
    private let userLocationManager: UserLocationManager
    
    private var lastUserLocation: CLLocation?
    
    private let generationSereialQueue = DispatchQueue(label: "generationSereialQueue")
    
    init(placesManager: PlacesManager, userLocationManager: UserLocationManager)
    {
        self.placesManager = placesManager
        self.userLocationManager = userLocationManager
        
        self.userLocationManager.userCoordinate.subscribe(onNext: { [weak self] (userCoordinate) in
            guard let coordinate = userCoordinate else {
                return
            }
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            self?.lastUserLocation = location
        }).disposed(by: disposeBug)
    }
    
    func createPlaces(countLat: Int, countLon: Int)
    {
        generationSereialQueue.async
        {
            let stepLat = 180.0 / Double(countLat)
            let stepLon = 360.0 / Double(countLon)
            
            for lat in stride(from: -90.0, to: 90.0, by: stepLat)
            {
                for lon in stride(from: -180.0, to: 180.0, by: stepLon)
                {
                    guard let place = self.placesManager.createPlace() else {
                        continue
                    }
                    
                    var distanceToUser = 0.0
                    if let userLocation = self.lastUserLocation
                    {
                        let placeLocation = CLLocation(latitude: place.lat, longitude: place.lon)
                        distanceToUser = userLocation.distance(from: placeLocation)
                    }
                    
                    self.placesManager.context.perform {
                        place.lat = lat
                        place.lon = lon
                        place.distance = distanceToUser
                    }
                    self.placesManager.saveContext()
                    
                    //Thread.sleep(forTimeInterval: 0.01)
                }
            }
        }
    }
}
