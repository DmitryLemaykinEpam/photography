//
//  UserLocationManager+GPXSimulation.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 1/21/19.
//  Copyright © 2019 Dmitry Lemaykin. All rights reserved.
//
//  At the moment of wring xCode 10 and 10.1 got broken Location similaton, so this is manul persing
//  and generator

import Foundation
import MapKit
import RxSwift

class UserLocationSimulator
{
    var gpxPoints = [GPXPoint]()
    
    var currentIndex: Int?
    
    init(userLocationManager: UserLocationManager)
    {
        userLocationManager.userCoordinate.bind(to: self.userCoordinate).disposed(by: disposeBag)
    }
    
    private let simulationQueue = DispatchQueue(label: "simulationSerealQueu")
    
    var disposeBag = DisposeBag()
    var userCoordinate = BehaviorSubject<CLLocationCoordinate2D?>(value: nil)
    
    func simulate(GPSFileName: String)
    {
        let parser = GPXParser()
        guard  parser.parse(fileName: GPSFileName) == true else {
            return
        }
        
        self.gpxPoints = parser.points
        
        guard self.gpxPoints.count > 0 else {
            return
        }
        
        self.currentIndex = 0
        let simulationBlock =
        {
            for _ in 0..<self.gpxPoints.count
            {
                guard let currentIndex = self.currentIndex,
                      currentIndex < self.gpxPoints.count else
                {
                    return
                }
                
                let prevPoint = self.gpxPoints[currentIndex]
                
                let nextIndex = currentIndex + 1
                let nextPoint = self.gpxPoints[nextIndex]

                let date1 = prevPoint.time
                let date2 = nextPoint.time
                
                let diffTimeInterval = date2!.timeIntervalSince1970 - date1!.timeIntervalSince1970
                
                let nextLocation = CLLocationCoordinate2D(latitude: nextPoint.lat, longitude: nextPoint.lon)
                print("Generated user location: \(nextLocation)")
                self.userCoordinate.asObserver().onNext(nextLocation)
                print("Next user location will in: \(diffTimeInterval) seconds")
                Thread.sleep(forTimeInterval: diffTimeInterval)
                
                self.currentIndex = nextIndex
            }
        }
        
        simulationQueue.async(execute: simulationBlock)
    }
}

