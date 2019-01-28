//
//  VisiblePlacesManager.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 1/18/19.
//  Copyright © 2019 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import MapKit
import CoreData

import RxSwift

class VisiblePlacesManager: NSObject
{
    // MARK: - Init
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let _predicate = Variable<NSPredicate?>(nil)
    // In order to get notified of changes in Place model, all CRUD operations should use same NSManagedObjectContext
    let context: NSManagedObjectContext
    
    private var visiblePlacesFetchedResultsController = NSFetchedResultsController<Place>()
    
    init(context: NSManagedObjectContext)
    {
        self.context = context
        
        super.init()
        
        _predicate.asObservable()
            .subscribe(onNext: { [weak self] predicate in
                if let predicate = predicate
                {
                    guard let self = self else {
                        return
                    }
                    
                    let fetchRequest = NSFetchRequest<Place>(entityName: "Place")
                    fetchRequest.sortDescriptors = []
                    fetchRequest.predicate = predicate
                    
                    let fetchedResultsController = NSFetchedResultsController<Place>(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
                    self.visiblePlacesFetchedResultsController = fetchedResultsController
                    self.visiblePlacesFetchedResultsController.delegate = self
                    
                    do {
                        try self.visiblePlacesFetchedResultsController.performFetch()
                        self.visiblePlacesCount.value = self.visiblePlacesFetchedResultsController.fetchedObjects?.count
                    } catch {
                        print(error)
                    }
                }
                else
                {
                    //TBD
                }
        })
        .disposed(by: disposeBag)
    }
    
    func updateVisibleArea(neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D)
    {
        let minLat = min(neCoordinate.latitude, swCoordinate.latitude)
        let maxLat = max(neCoordinate.latitude, swCoordinate.latitude)
        
        let minLon = min(neCoordinate.longitude, swCoordinate.longitude)
        let maxLon = max(swCoordinate.longitude, neCoordinate.longitude)
        
        let minLatNSNumber = NSNumber(value:minLat)
        let maxLatNSNumber = NSNumber(value:maxLat)
        
        let minLonNSNumber = NSNumber(value:minLon)
        let maxLonNSNumber = NSNumber(value:maxLon)
        
        let predicate = NSPredicate(format: "\(minLatNSNumber) <= lat AND lat <= \(maxLatNSNumber) AND \(minLonNSNumber) <= lon AND lon <= \(maxLonNSNumber)")
        print("predicateN: \(predicate)")
        
        self._predicate.value = predicate
    }
    
    // MARK: - Output
    fileprivate let _visibleLocationsChanges = PublishSubject<Change<Place>>()
    public var visibleLocationsChanges: Observable<Change<Place>> {
        return _visibleLocationsChanges.asObservable()
    }
    
    public let visiblePlacesCount = Variable<Int?>(nil)
    
    public func visiblePlace(index: Int) -> Place?
    {
        return visiblePlacesFetchedResultsController.fetchedObjects?[index]
    }
    
    // MARK: - Methods
    func visiblePlace(_ placeId: String) -> Place?
    {
        let place = self.visiblePlacesFetchedResultsController.fetchedObjects?.first(where: { (place) -> Bool in
            return place.placeId() == placeId
        })
        
        return place
    }
}

extension VisiblePlacesManager: NSFetchedResultsControllerDelegate
{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        let count = controller.fetchedObjects?.count
        if visiblePlacesCount.value != count {
            visiblePlacesCount.value = count
        }
        
        guard let place = anObject as? Place else {
            print("ERROR: anObject is not a Loaction")
            return
        }
        
        let action: Action
        switch type
        {
        case .insert:
            action = .insert(indexPath: newIndexPath!)
            
        case .delete:
            action = .delete(indexPath: indexPath!)
            
        case .update:
            action = .update(indexPath: indexPath!)
            
        case .move:
            action = .move(from: indexPath!, to: newIndexPath!)
        }
        
        let change = Change(anObject: place, action: action)
        _visibleLocationsChanges.onNext(change)
    }
}

