//
//  Moc.swift
//  PhotographyStartupTests
//
//  Created by Dmitry Lemaykin on 9/12/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import XCTest
@testable import PhotographyStartup

class VisibleLocationsManagerDelegate_Moc : LocationsManagerDelegate
{
    var location : Location?
    
    var didCall_locationAdded = false
    var didCall_locationRemoved = false
    var didCall_locationsReloaded = false
    var didCall_locationUpdated = false
    
    func locationAdded(_ location: Location)
    {
        didCall_locationAdded = true
        self.location = location
    }
    
    func locationUpdated(_ location: Location)
    {
        didCall_locationUpdated = true
        self.location = location
    }
    
    func locationRemoved(_ location: Location)
    {
        didCall_locationRemoved = true
        self.location = location
    }
    
    func locationsReloaded() {
        didCall_locationsReloaded = true
    }
}
