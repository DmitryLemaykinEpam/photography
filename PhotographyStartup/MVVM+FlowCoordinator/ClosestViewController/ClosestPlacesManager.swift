//
//  ClosestPlacesManager.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 1/18/19.
//  Copyright © 2019 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import RxSwift
import MagicalRecord
import MapKit

class ClosestPlacesManager: NSObject
{
    // MARK: - Init
    fileprivate let disposeBag = DisposeBag()
    fileprivate let placesManager: PlacesManager
    fileprivate let userLocationManager: UserLocationManager
    fileprivate let updateDistanceOperationQueue = OperationQueue()
    
    let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
    
    let childContext: NSManagedObjectContext
    
    init(parentContext: NSManagedObjectContext, userLocationManager: UserLocationManager, placesManager: PlacesManager)
    {
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = parentContext
        
        self.childContext = childContext
        
        self.placesManager = placesManager
        self.userLocationManager = userLocationManager
        
        super.init()

        reFetchPlaces()
        
        self.userLocationManager.userCoordinate
            .observeOn(globalScheduler)
            .subscribe(onNext: { userCoordinate in
                guard let userCoordinate = userCoordinate else {
                    return
                }
                let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
                
                let updateDistanceOperation = UpdateDistanceOperation(userLocation, parentContext: self.childContext, closestPlacesManager: self)
                
                self.updateDistanceOperationQueue.cancelAllOperations()
                self.updateDistanceOperationQueue.addOperations([updateDistanceOperation], waitUntilFinished: true)
                
                self.reFetchPlaces()
            })
            .disposed(by: disposeBag)
    }
    
    var sortedPlaces: [Place]?
    
    func reFetchPlaces()
    {
        let sortedPlacesFetchRequest = NSFetchRequest<Place>(entityName: "Place")
        sortedPlacesFetchRequest.sortDescriptors = [NSSortDescriptor(key: "distance", ascending: true)]
        
        self.childContext.perform {
            do {
                self.sortedPlaces = try self.childContext.fetch(sortedPlacesFetchRequest)
                
                print("sortedPlaces[0].distance: \(self.sortedPlaces![0].distance)")
                print("sortedPlaces[1].distance: \(self.sortedPlaces![1].distance)")
                print("sortedPlaces[2].distance: \(self.sortedPlaces![2].distance)")
                
            } catch {
                print("Failed to fetch employees: \(error)")
                return
            }
            
            self.closestPlacesCount.value = self.sortedPlaces?.count
        }
    }
    
    func saveContext(context: NSManagedObjectContext)
    {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Output
    let distanceUpdated = PublishSubject<Bool>()
    
    fileprivate let _closestPlacesChanges = PublishSubject<Change<Place>>()
    public var closestPlacesChanges: Observable<Change<Place>> {
        return _closestPlacesChanges.asObservable()
    }
    
    public let closestPlacesCount = Variable<Int?>(nil)
    
    public func closestPlace(index: Int) -> Place?
    {
        var place: Place?
        self.childContext.performAndWait {
            guard let places = self.sortedPlaces else {
                return
            }
            
            guard index < places.count else {
                return
            }
            
            place = places[index]
        }
        return place
    }
    
    public func closestPlace(index: Int, complition: @escaping (Place?) -> Void)
    {
        self.childContext.perform {
            guard let places = self.sortedPlaces else {
                return complition(nil)
            }
            
            guard index < places.count else {
                return complition(nil)
            }
            
            let place = places[index]
            complition(place)
        }
    }
}

class UpdateDistanceOperation: Operation
{
    let childContext: NSManagedObjectContext
    let userLocation: CLLocation
    let closestPlacesManager: ClosestPlacesManager
    
    init(_ userLocation: CLLocation, parentContext: NSManagedObjectContext, closestPlacesManager: ClosestPlacesManager)
    {
        self.userLocation = userLocation
        self.closestPlacesManager = closestPlacesManager

        self.childContext = parentContext

        super.init()
        
        self.qualityOfService = .utility
    }
    
    override func main()
    {
        if isCancelled {
            return
        }
        
        let allPlacesFetchRequest = NSFetchRequest<Place>(entityName: "Place")
        
        var allPlacesFetchResult: [Place]?
        
        self.childContext.performAndWait {
            do {
                allPlacesFetchResult = try self.childContext.fetch(allPlacesFetchRequest)
            } catch {
                print("Failed to fetch employees: \(error)")
                return
            }
        }
        guard let allPlaces = allPlacesFetchResult,
                allPlaces.count > 0 else {
            return
        }
        
        var distances = [CLLocationDistance]()
        for place in allPlaces
        {
            let placeLocation = CLLocation(latitude: place.lat, longitude: place.lon)
            
            let distanceToUser = userLocation.distance(from: placeLocation)
            distances.append(distanceToUser)
        }
        
        if self.isCancelled {
            print("Distence recalculation Canceled: Before distance update")
            return
        }
        
        childContext.perform {
            for index in 0..<allPlaces.count
            {
                let place = allPlaces[index]
            
                let distanceToUser = distances[index]
                place.distance = distanceToUser
            }
        }
        
        if self.isCancelled {
            print("Distence recalculation Canceled: Before childContext save()")
            return
        }
        
        //
        childContext.perform {
            guard self.childContext.hasChanges else {
                return
            }
            do {
                try self.childContext.save()
            } catch {
                print(error)
            }
        }
    }
}
