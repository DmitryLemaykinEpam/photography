//
//  File.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/19/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import CoreLocation
import Bond

class UserLocationManager: NSObject
{
    var tracking = Observable<Bool>(false)
    var userCoordinate = Observable<CLLocationCoordinate2D?>(nil)
    
    private lazy var clLocationManager: CLLocationManager = { [unowned self] in
        let clLocationManager = CLLocationManager()
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest

        return clLocationManager
    }()

    func startTarckingUserLoaction()
    {
        clLocationManager.requestWhenInUseAuthorization()
    }
    
    func stopTarckingUserLoaction()
    {
        clLocationManager.stopUpdatingLocation()
    }
}

extension UserLocationManager : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
        case .notDetermined:
            clLocationManager.stopUpdatingLocation()
            
        case .denied:
            clLocationManager.stopUpdatingLocation()
            
        case .authorizedAlways:
            clLocationManager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            clLocationManager.startUpdatingLocation()
            
        case .restricted:
            clLocationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)
    {
        tracking.value = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let latestLocation = locations.last else {
            print("Error: could not get latest location")
            return
        }
        
        userCoordinate.value = latestLocation.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?)
    {
        tracking.value = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error: " + error.localizedDescription)
        tracking.value = false
    }
}
