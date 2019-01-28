//
//  Moc.swift
//  PhotographyStartupTests
//
//  Created by Dmitry Lemaykin on 9/12/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import XCTest
@testable import PhotographyStartup

class PlacesManagerDelegate_Moc : PlacesManagerDelegate
{
    var place : Place?
    
    var didCall_placeAdded = false
    var didCall_placeRemoved = false
    var didCall_placeReloaded = false
    var didCall_placeUpdated = false
    
    func placeAdded(_ newPlace: Place)
    {
        self.didCall_placeAdded = true
        self.place = newPlace
    }
    
    func placeUpdated(_ updatedPlace: Place, indexPath: IndexPath?)
    {
        self.didCall_placeUpdated = true
        self.place = updatedPlace
    }
    
    func placeRemoved(_ placeToRemove: Place)
    {
        self.didCall_placeRemoved = true
        self.place = placeToRemove
    }
    
    func placesReloaded() {
        self.didCall_placeReloaded = true
    }
}
