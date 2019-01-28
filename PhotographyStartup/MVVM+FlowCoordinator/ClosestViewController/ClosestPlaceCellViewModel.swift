//
//  CustomLocationViewModel.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class ClosestPlaceCellViewModel
{
    // MARK: - Init
    private let disposeBag = DisposeBag()
    
    private let placesManager: PlacesManager
    private let closestPlacesManager: ClosestPlacesManager
    
    private let globalScheduler = ConcurrentDispatchQueueScheduler(queue:
        DispatchQueue.global())
    
    let index: Int
    
    init(index: Int, closestPlacesManager: ClosestPlacesManager, placesManager: PlacesManager)
    {
        self.index = index
        self.placesManager = placesManager
        
        self.closestPlacesManager = closestPlacesManager
        self.closestPlacesManager.closestPlacesChanges
            .observeOn(globalScheduler)
            .subscribe(onNext: { [weak self] (change) in
                guard let self = self else {
                    return
                }
                
                switch change.action
                {
                case .insert(let indexPath):
                    let index = indexPath.row
                    if self.index == index {
                        self.place = change.anObject
                    } else if self.index > index {
                        self.place = self.closestPlacesManager.closestPlace(index: self.index)
                    }
                    
                case .delete(let indexPath):
                    let index = indexPath.row
                    if self.index == index {
                        self.place = change.anObject
                    } else if self.index > index {
                        self.place = self.closestPlacesManager.closestPlace(index: self.index)
                    }
                    
                case .update(let indexPath):
                    let index = indexPath.row
                    if index == self.index {
                        self.place = change.anObject
                    }
                    
                case .move(let from, let to):
                    let fromIndex = from.row
                    let toIndex = to.row
                    if self.index == fromIndex ||
                       self.index == toIndex
                    {
                        self.place = change.anObject
                    } else {
    //                    let topIndex   = min(fromIndex, toIndex)
    //                    let botomIndex = max(fromIndex, toIndex)
    //                    if self.index > topIndex &&
    //                       self.index < botomIndex
    //                    {
    //                        self.place = self.closestPlacesManager.closestPlace(index: self.index)
    //                    }
                    }
                }
        }).disposed(by: disposeBag)
        
//        self.closestPlacesManager.distanceUpdated
//            .observeOn(globalScheduler)
//            .subscribe(onNext: { (_) in
//                self.place = self.closestPlacesManager.closestPlace(index: self.index)
//            })
//            .disposed(by: disposeBag)
        
        self.closestPlacesManager.closestPlacesCount.asObservable()
            .observeOn(globalScheduler)
            .subscribe(onNext: { (_) in
                self.closestPlacesManager.closestPlace(index: self.index, complition: { (place) in
                    self.place = place
                })
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Input
    
    // MARK: - Output
    public let changed = PublishSubject<Bool>()
    
    var placeId: String?
    var coordinate = CLLocationCoordinate2D()
    var name = BehaviorSubject<String?>(value:nil)
    
    
    var notes = ""
    public let distance = BehaviorSubject<Double>(value:0)
    
    private var _place: Place?
    var place: Place? {
        get {
            return _place
        }
        set {
            _place = newValue
            
            guard let newPlace = _place else {
                return
            }
            
            self.placeId = newPlace.placeId()
            self.coordinate = CLLocationCoordinate2D(latitude: newPlace.lat, longitude: newPlace.lon)
            self.name.onNext(newPlace.name)
            self.notes = newPlace.notes ?? "Notes is not provided yet"
            self.distance.onNext(newPlace.distance)
            self.changed.onNext(true)
        }
    }
    
    private var _removed = Variable<Bool>(false)
    public var removed: Observable<Bool> {
        return _removed.asObservable()
    }
    
    // MARK: - Methods
}

extension ClosestPlaceCellViewModel: Equatable
{
    public static func == (lhs: ClosestPlaceCellViewModel, rhs: ClosestPlaceCellViewModel) -> Bool
    {
        let result = lhs.placeId == rhs.placeId ? true : false
        return result
    }
}
