//
//  File.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/19/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import CoreLocation

protocol UserLocationManagerDelegate : class
{
    func userDidChangeCoordinate(_ newUserCoordinate: CLLocationCoordinate2D)
}

class UserLocationManager: NSObject
{
    weak var delegate: UserLocationManagerDelegate?
    
    private lazy var clLocationManager = CLLocationManager()
    
    func servicesEnabled() -> Bool
    {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func startTarckingUserLoaction()
    {
        clLocationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled()
        {
            clLocationManager.delegate = self
            clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
            clLocationManager.startUpdatingLocation()
        }
    }
    
    func stopTarckingUserLoaction()
    {
        clLocationManager.stopUpdatingLocation()
    }
    
    func userCoordinate() -> CLLocationCoordinate2D?
    {
        return clLocationManager.location?.coordinate
    }
}

extension UserLocationManager : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard locations.count > 0 else {
            return
        }
        
        guard let latestLocation = locations.last else {
            print("Error: could not get latest location")
            return
        }
        
        let newUserCoordinate = latestLocation.coordinate

        delegate?.userDidChangeCoordinate(newUserCoordinate)
    }
}

