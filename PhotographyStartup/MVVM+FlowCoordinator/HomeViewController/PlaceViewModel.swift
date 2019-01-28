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

class PlaceViewModel
{
    // MARK: - Init
    private let disposeBag = DisposeBag()
    
    private let placesManager: PlacesManager
    
    init(placesManager: PlacesManager)
    {
        self.placesManager = placesManager
    }
    
    // MARK: - Input
    
    // MARK: - Output
    public let changed = BehaviorSubject<Bool>(value: true)
    
    var placeId: String?
    var coordinate = CLLocationCoordinate2D()
    let name = Variable<String?>(nil)
    var notes = ""
    
    var _place: Place?
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
            self.name.value = newPlace.name
            self.notes = newPlace.notes ?? "Notes is not provided yet" 
            self.distance.value = newPlace.distance
            
            self.changed.onNext(true)
        }
    }
    
    public let distance = Variable<Double>(0)
    
    private var _removed = Variable<Bool>(false)
    public var removed: Observable<Bool> {
        return _removed.asObservable()
    }
    
    // MARK: - Methods
    func save()
    {
        guard let place = self.place else {
            print("Error: don't have place to save")
            return
        }
        
        place.name = name.value
        place.notes = notes
        
        place.lat = coordinate.latitude
        place.lon = coordinate.longitude
        
        guard let placeContext = place.managedObjectContext else {
            print("ERROR: place dont have context: \(place)")
            return
        }
        
        self.placesManager.saveContext(context: placeContext)
    }
    
    public func remove()
    {
        _removed.value = true
    }
}

extension PlaceViewModel: Equatable
{
    public static func == (lhs: PlaceViewModel, rhs: PlaceViewModel) -> Bool
    {
        let result = lhs.placeId == rhs.placeId ? true : false
        return result
    }
}
