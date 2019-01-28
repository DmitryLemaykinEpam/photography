//
//  ClosestPlacesViewModel.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/21/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import MapKit

import RxSwift
import RxCocoa

class ClosestPlacesViewModel: ClosestPlacesViewModelProtocol
{
    // MARK: - Init
    fileprivate let disposeBag = DisposeBag()
    
    private let placesManager: PlacesManager
    private let userLocationManager: UserLocationManager
    private let closestPlacesManager: ClosestPlacesManager
    
    private let globalScheduler = ConcurrentDispatchQueueScheduler(queue:
        DispatchQueue.global())
    
    init(placesManager: PlacesManager, userLocationManager: UserLocationManager, closestPlacesManager: ClosestPlacesManager)
    {
        self.placesManager = placesManager
        self.userLocationManager = userLocationManager
        
        self.userLocationManager.userCoordinate.bind(to: self._userCoordinate).disposed(by: disposeBag)
        
        self.closestPlacesManager = closestPlacesManager
        
        self.closestPlacesManager.closestPlacesCount.asObservable().bind(to: self.closestPlacesCount).disposed(by: disposeBag)
        
        self.closestPlacesManager.closestPlacesChanges
            .observeOn(globalScheduler)
            .filter { (change) -> Bool in
                switch change.action
                {
                case .insert(_):
                    return false
                case .delete(_):
                    return false

                case .update(_):
                    return true
                case .move(_, _):
                    return true
                }
            }
            .subscribe(onNext: { [weak self] (change) in
                guard let self = self else {
                    return
                }
                
                var index: Int
                switch change.action
                {
                case .insert(let indexPath):
                    index = indexPath.row
                    
                case .delete(let indexPath):
                    index = indexPath.row
                    
                case .update(let indexPath):
                    index = indexPath.row
                    
                case .move(_, let to):
                    index = to.row
                }
            
            let placeVM = ClosestPlaceCellViewModel(index: index, closestPlacesManager: self.closestPlacesManager, placesManager: self.placesManager)
            placeVM.place = change.anObject
            let changeVM = Change(anObject: placeVM, action: change.action)
            
            self._closestPlacesViewModelsChanges.onNext(changeVM)
        })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Input
    
    // MARK: - Output
    private let _userCoordinate = Variable<CLLocationCoordinate2D?>(nil)
    public var userCoordinate: Observable<CLLocationCoordinate2D?> {
        return _userCoordinate.asObservable()
    }
    
    private let _closestPlacesViewModelsChanges = PublishSubject<Change<ClosestPlaceCellViewModel>>()
    public var closestPlacesViewModelsChanges: Observable<Change<ClosestPlaceCellViewModel>> {
        return _closestPlacesViewModelsChanges.asObservable()
    }
    
    public let closestPlacesCount = Variable<Int?>(nil)
    public func closestPlaceViewModel(index: Int) -> ClosestPlaceCellViewModel?
    {
        let closestPlaceVM = ClosestPlaceCellViewModel(index: index, closestPlacesManager: closestPlacesManager, placesManager: placesManager)
        
//        closestPlaceVM.place = self.closestPlacesManager.closestPlace(index: index)
        self.closestPlacesManager.closestPlace(index: index) { (place) in
            closestPlaceVM.place = place
        }
        
        return closestPlaceVM
    }
    
    // MARK: - Methods
    
    func createPlace()
    {
        let placesGenerator = PlaceGenereator(placesManager: self.placesManager, userLocationManager: self.userLocationManager)
        placesGenerator.createPlaces(countLat: 100, countLon: 100)
    }
    
    func startTrackingUserLoaction()
    {
        userLocationManager.startTarckingUserLoaction()
    }
    
    func stopTrackingUserLoaction()
    {
        userLocationManager.stopTarckingUserLoaction()
    }
}
