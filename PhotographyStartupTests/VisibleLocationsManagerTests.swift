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
    var visibleLocationsManager : LocationsManager!
    var mocDelegate : VisibleLocationsManagerDelegate_Moc!
    
    override func setUp() {
        super.setUp()

        mocDelegate = VisibleLocationsManagerDelegate_Moc()
        XCTAssertNotNil(mocDelegate)

        visibleLocationsManager = LocationsManager()
        XCTAssertNotNil(visibleLocationsManager)
        visibleLocationsManager.fetch()

        XCTAssertTrue(CustomLocation.mr_findAll()?.count == 0)
    }

    override func tearDown()
    {
        visibleLocationsManager = nil
        mocDelegate = nil

        super.tearDown()
    }
    
    func testVisibleLocationsManager_CreateNewCustomLocation_Success()
    {
        visibleLocationsManager.delegate = mocDelegate
        let location = visibleLocationsManager.createNewCustomLocation()
        visibleLocationsManager.saveToPersistentStore()

        XCTAssertNotNil(location)
        XCTAssertTrue(CustomLocation.mr_findAll()?.count == 1)
        XCTAssertTrue(visibleLocationsManager.allVisibleLocations()?.count == 1)
        XCTAssertFalse(mocDelegate.didCall_removeCustomLocation)
        XCTAssertTrue(mocDelegate.didCall_addCustomLocation)
        XCTAssertFalse(mocDelegate.didCall_reloadAllCustomLocation)
    }
    
    func testVisibleLocationsManager_RemoveCustomeLocation_Success()
    {
        guard let location = visibleLocationsManager.createNewCustomLocation() else {
            XCTFail()
            return
        }
        location.name = "Name"
        location.lat = 1000.0
        location.lon = 1000.0
        visibleLocationsManager.saveToPersistentStore()
        XCTAssertTrue(visibleLocationsManager.allVisibleLocations()?.count == 1)
        
        visibleLocationsManager.delegate = mocDelegate
        visibleLocationsManager.removeCustomeLocation(lat: location.lat, lon: location.lon)
        visibleLocationsManager.saveToPersistentStore()
        
        XCTAssertTrue(CustomLocation.mr_findAll()?.count == 0)
        XCTAssertTrue(mocDelegate.didCall_removeCustomLocation)
        XCTAssertFalse(mocDelegate.didCall_addCustomLocation)
        XCTAssertFalse(mocDelegate.didCall_reloadAllCustomLocation)
    }
    
    func testVisibleLocationsManager_CreateNewCustomLocation_Fast()
    {
        self.measure {
            for _ in 0..<1000
            {
                let location = visibleLocationsManager.createNewCustomLocation()
                XCTAssertNotNil(location)
            }
        }
    }
}
