//
//  File.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/19/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

class UserLocationManager: NSObject
{
    // MARK: - Init
    fileprivate lazy var clLocationManager: CLLocationManager = { [unowned self] in
        let clLocationManager = CLLocationManager()
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest

        return clLocationManager
    }()
    
    // MARK: - Input
    
    
    // MARK: - Output
    
    fileprivate var _isTracking = Variable<Bool>(false)
    public var isTracking: Observable<Bool> {
        return _isTracking.asObservable().distinctUntilChanged()
    }
    
    public var userCoordinate = BehaviorSubject<CLLocationCoordinate2D?>(value: nil)
    
    // MARK: - Methods
    func startTarckingUserLoaction()
    {
        if _isTracking.value == true {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways {
            clLocationManager.startUpdatingLocation()
        } else {
            clLocationManager.requestWhenInUseAuthorization()
        }
    }
    
    func stopTarckingUserLoaction()
    {
        clLocationManager.stopUpdatingLocation()
    }
}

extension UserLocationManager: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
        case .notDetermined:
            _isTracking.value = false
            
        case .denied:
            _isTracking.value = false
            
        case .authorizedAlways:
            clLocationManager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            clLocationManager.startUpdatingLocation()
            
        case .restricted:
            _isTracking.value = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)
    {
        _isTracking.value = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let latestLocation = locations.last else {
            print("ERROR: could not get latest location")
            return
        }
        
        print("UserLocationManager: latestLocation.coordinate: \(latestLocation.coordinate)")
        userCoordinate.onNext(latestLocation.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?)
    {
        _isTracking.value = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("ERROR: " + error.localizedDescription)
        _isTracking.value = false
    }
}
