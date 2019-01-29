//
//  HomeViewModel.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/20/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import MapKit

import RxSwift
import RxCocoa

class HomeViewModel
{
    // MARK: - Init
    private var disposeBag = DisposeBag()
    
    private let visiblePlacesManager: VisiblePlacesManager
    private let placesManager: PlacesManager
    private let userLocationManager: UserLocationManager
    
    init(visiblePlacesManager: VisiblePlacesManager, placesManager: PlacesManager, userLocationManager: UserLocationManager)
    {
        self.placesManager = placesManager
        
        self.userLocationManager = userLocationManager
        self.userLocationManager.userCoordinate.bind(to: self._userCoordinate).disposed(by: disposeBag)
        
        self.visiblePlacesManager = visiblePlacesManager
        self.visiblePlacesManager.visibleLocationsChanges.subscribe(onNext: { [weak self] change in
            guard let self = self else {
                return
            }
            
            let placeVM = PlaceViewModel(placesManager: self.placesManager)
            placeVM.place = change.anObject
            
            let changeVM = Change(anObject: placeVM, action: change.action)
            self._visiblePlacesViewModelsChanges.onNext(changeVM)
        })
            .disposed(by: self.disposeBag)
        
        self.visiblePlacesManager.visiblePlacesCount.asObservable().bind(to: self.visiblePlacesCount).disposed(by: disposeBag)
    }
    
    // MARK: - Input
    
    // MARK: - Output
    private let _userCoordinate = Variable<CLLocationCoordinate2D?>(nil)
    public var userCoordinate: Observable<CLLocationCoordinate2D?> {
        return _userCoordinate.asObservable()
    }
    
    public let visiblePlacesCount = Variable<Int?>(nil)
    public func visiblePlace(index: Int) -> PlaceViewModel?
    {
        guard let place = visiblePlacesManager.visiblePlace(index: index) else {
            return nil
        }
        
        let placeVM = PlaceViewModel(placesManager: placesManager)
        placeVM.place = place
        
        return placeVM
    }
    
    private let _visiblePlacesViewModelsChanges = PublishSubject<Change<PlaceViewModel>>()
    public var visiblePlacesViewModelsChanges: Observable<Change<PlaceViewModel>> {
        return _visiblePlacesViewModelsChanges.asObservable()
    }
}

// MARK: - HomeViewModelProtocol
extension HomeViewModel: HomeViewModelProtocol
{
    func placeViewModelFor(placeId: String?) -> PlaceViewModel?
    {
        guard let placeId = placeId,
            let place = visiblePlacesManager.visiblePlace(placeId) else {
            return nil
        }
        
        let placeViewModel = PlaceViewModel(placesManager: self.placesManager)
        placeViewModel.place = place
        
        return placeViewModel
    }
    
    func startTarckingUserLoaction()
    {
        userLocationManager.startTarckingUserLoaction()
    }
    
    func stopTarckingUserLoaction()
    {
        userLocationManager.stopTarckingUserLoaction()
    }
    
    func updateVisibleArea(neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D)
    {
        visiblePlacesManager.updateVisibleArea(neCoordinate: neCoordinate, swCoordinate: swCoordinate)
    }
    
    func createLocationViewModel() -> PlaceViewModel?
    {
        guard let place = placesManager.createPlace() else {
            print("Error: could not create location for view model")
            return nil
        }
        
        let placeViewModel = PlaceViewModel(placesManager: placesManager)
        placeViewModel.place = place
        
        return placeViewModel
    }
    
    func removePlace(_ placeId: String)
    {
        guard let place = placesManager.placeFor(placeId: placeId) else {
            print("Error: could not get Locations for LocationsViewModel")
            return
        }
        
        placesManager.removePlace(place)
        placesManager.saveContext()
    }
}
