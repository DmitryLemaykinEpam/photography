//
//  VisibleLocationsManagerTests.swift
//  PhotographyStartupTests
//
//  Created by Dmitry Lemaykin on 9/12/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import XCTest
import MagicalRecord
@testable import PhotographyStartup

class VisibleLocationsManagerTests: CoreDataTestCase
{
    var locationsManager : LocationsManager!
    var mocDelegate : VisibleLocationsManagerDelegate_Moc!
    
    override func setUp() {
        super.setUp()

        mocDelegate = VisibleLocationsManagerDelegate_Moc()
        XCTAssertNotNil(mocDelegate)

        locationsManager = LocationsManager()
        XCTAssertNotNil(locationsManager)
        locationsManager.fetch()

        XCTAssertTrue(Location.mr_findAll()?.count == 0)
    }

    override func tearDown()
    {
        locationsManager = nil
        mocDelegate = nil

        super.tearDown()
    }
    
    func testVisibleLocationsManager_CreateNewCustomLocation_Success()
    {
        locationsManager.delegate = mocDelegate
        let location = locationsManager.createLocation()
        locationsManager.saveToPersistentStore()

        XCTAssertNotNil(location)
        XCTAssertTrue(Location.mr_findAll()?.count == 1)
        XCTAssertTrue(locationsManager.visibleLocations()?.count == 1)
        XCTAssertFalse(mocDelegate.didCall_locationRemoved)
        XCTAssertTrue(mocDelegate.didCall_locationAdded)
        XCTAssertFalse(mocDelegate.didCall_locationsReloaded)
    }
    
    func testVisibleLocationsManager_RemoveCustomeLocation_Success()
    {
        guard let location = locationsManager.createLocation() else {
            XCTFail()
            return
        }
        location.name = "Name"
        location.lat = 1000.0
        location.lon = 1000.0
        locationsManager.saveToPersistentStore()
        XCTAssertTrue(locationsManager.visibleLocations()?.count == 1)
        
        locationsManager.delegate = mocDelegate
        locationsManager.removeLocation(location)
        locationsManager.saveToPersistentStore()
        
        XCTAssertTrue(Location.mr_findAll()?.count == 0)
        XCTAssertTrue(mocDelegate.didCall_locationRemoved)
        XCTAssertFalse(mocDelegate.didCall_locationAdded)
        XCTAssertFalse(mocDelegate.didCall_locationsReloaded)
    }
    
    func testVisibleLocationsManager_CreateNewCustomLocation_Fast()
    {
        self.measure {
            for _ in 0..<1000
            {
                let location = locationsManager.createLocation()
                XCTAssertNotNil(location)
            }
        }
    }
}
