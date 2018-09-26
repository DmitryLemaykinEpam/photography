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
    var mocDelegate : LocationsManagerDelegate_Moc!
    
    override func setUp() {
        super.setUp()

        mocDelegate = LocationsManagerDelegate_Moc()
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
    
    func testLocationsManager_CreateNewLocation_Success()
    {
        let name = "Name"
        let notes = "notes"
        let lat: Double = 101.0
        let lon: Double = 102.0
        
        locationsManager.delegate = mocDelegate
        let location = locationsManager.createLocation()
        location?.name = name
        location?.notes = notes
        location?.lat = lat
        location?.lon = lon
        locationsManager.saveToPersistentStore()

        XCTAssertNotNil(location)
        let resultLocations = Location.mr_findAll()
        XCTAssertTrue(resultLocations?.count == 1)
        guard let resultLocation = resultLocations?.first as? Location else {
            XCTFail()
            return
        }
        XCTAssertTrue(resultLocation.name == name)
        XCTAssertTrue(resultLocation.notes == notes)
        XCTAssertTrue(resultLocation.lat == lat)
        XCTAssertTrue(resultLocation.lon == lon)
        
        XCTAssertTrue(locationsManager.visibleLocations()?.count == 1)
        XCTAssertFalse(mocDelegate.didCall_locationRemoved)
        XCTAssertTrue(mocDelegate.didCall_locationAdded)
        XCTAssertFalse(mocDelegate.didCall_locationsReloaded)
    }
    
    func testLocationsManager_RemoveLocation_Success()
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
    
    func testLocationsManager_CreateNewLocation_Fast()
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
