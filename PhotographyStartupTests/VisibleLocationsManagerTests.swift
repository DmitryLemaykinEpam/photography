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
    var placesManager : PlacesManager!
    var mocDelegate : PlacesManagerDelegate_Moc!
    
    override func setUp() {
        super.setUp()

        mocDelegate = PlacesManagerDelegate_Moc()
        XCTAssertNotNil(mocDelegate)

        placesManager = PlacesManager()
        XCTAssertNotNil(placesManager)
        placesManager.fetch()

        XCTAssertTrue(Place.mr_findAll()?.count == 0)
    }

    override func tearDown()
    {
        placesManager = nil
        mocDelegate = nil

        super.tearDown()
    }
    
    func testLocationsManager_CreateNewLocation_Success()
    {
        let name = "Name"
        let notes = "notes"
        let lat: Double = 101.0
        let lon: Double = 102.0
        
        placesManager.delegate = mocDelegate
        let place = placesManager.createPlace()
        place?.name = name
        place?.notes = notes
        place?.lat = lat
        place?.lon = lon
        placesManager.saveToPersistentStore()

        XCTAssertNotNil(place)
        let resultLocations = Place.mr_findAll()
        XCTAssertTrue(resultLocations?.count == 1)
        guard let resultLocation = resultLocations?.first as? Place else {
            XCTFail()
            return
        }
        XCTAssertTrue(resultLocation.name == name)
        XCTAssertTrue(resultLocation.notes == notes)
        XCTAssertTrue(resultLocation.lat == lat)
        XCTAssertTrue(resultLocation.lon == lon)
        
        XCTAssertTrue(placesManager.visibleLocations()?.count == 1)
        XCTAssertFalse(mocDelegate.didCall_placeRemoved)
        XCTAssertTrue(mocDelegate.didCall_placeAdded)
        XCTAssertFalse(mocDelegate.didCall_placeReloaded)
    }
    
    func testLocationsManager_RemoveLocation_Success()
    {
        guard let place = placesManager.createPlace() else {
            XCTFail()
            return
        }
        place.name = "Name"
        place.lat = 1000.0
        place.lon = 1000.0
        placesManager.saveToPersistentStore()
        XCTAssertTrue(placesManager.visibleLocations()?.count == 1)
        
        placesManager.delegate = mocDelegate
        placesManager.removePlace(place)
        placesManager.saveToPersistentStore()
        
        XCTAssertTrue(Place.mr_findAll()?.count == 0)
        XCTAssertTrue(mocDelegate.didCall_placeRemoved)
        XCTAssertFalse(mocDelegate.didCall_placeAdded)
        XCTAssertFalse(mocDelegate.didCall_placeReloaded)
    }
    
    func testLocationsManager_CreateNewLocation_Fast()
    {
        self.measure {
            for _ in 0..<1000
            {
                let location = placesManager.createPlace()
                XCTAssertNotNil(location)
            }
        }
    }
}
