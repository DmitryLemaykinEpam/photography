//
//  VisibleLocationsManagerTests.swift
//  PhotographyStartupTests
//
//  Created by Dmitry Lemaykin on 9/12/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import XCTest
import MagicalRecord

class VisibleLocationsManagerTests: XCTestCase
{
    var manager : VisibleLocationsManager!
    var delegate : VisibleLocationsManagerDelegate_Moc!
    
    override func setUp() {
        super.setUp()
        
        MagicalRecord.setupCoreDataStack()
        for location in CustomLocation.mr_findAll()!
        {
            location.mr_deleteEntity()
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
        delegate = VisibleLocationsManagerDelegate_Moc()
        XCTAssertNotNil(delegate)
        
        manager = VisibleLocationsManager()
        XCTAssertNotNil(manager)
        manager.delegate = delegate
    }
    
    override func tearDown()
    {
        for location in CustomLocation.mr_findAll()!
        {
            location.mr_deleteEntity()
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        MagicalRecord.cleanUp()
        
        manager = nil
        delegate = nil
        
        super.tearDown()
    }
    
    func testVisibleLocationsManager_CreateNewCustomLocation_Success()
    {
        let location = manager.createNewCustomLocation()
        XCTAssertNotNil(location)
    }
    
    func testVisibleLocationsManager_CreateNewCustomLocation_DidCallDelegateMethod()
    {
        XCTAssertTrue(CustomLocation.mr_findAll()?.count == 0)
        
        //delegate.expectation = self.expectation(description: "")
        let location = manager.createNewCustomLocation()
        
        XCTAssertNotNil(location)
        XCTAssertTrue(CustomLocation.mr_findAll()?.count == 1)
//        waitForExpectations(timeout: 5, handler: nil)
//        XCTAssertTrue(delegate.didCall_addCustomLocation)
//        XCTAssertTrue(location == delegate.customLocation)
    }
    
    func testVisibleLocationsManager_CreateNewCustomLocation_Fast()
    {
        self.measure {
            for _ in 0..<1000
            {
                let location = manager.createNewCustomLocation()
                XCTAssertNotNil(location)
            }
        }
    }
}
