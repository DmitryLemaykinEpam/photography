//
//  CoreDataTestCase.swift
//  PhotographyStartupTests
//
//  Created by Dmitry Lemaykin on 9/13/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import XCTest
import MagicalRecord

class CoreDataTestCase : XCTestCase {
    
    override func setUp() {
        super.setUp()
        setUpCoreData()
    }
    
    override func tearDown() {
        super.tearDown()
        tearDownCoreData()
    }
}

extension XCTestCase {
    /*
     * Call these methods in setup and tear down of methods accessing core data
     */
    func setUpCoreData () {
        // Cleanup Core Data setup because there already is a context setup in the
        // AppDelegate. We do not want to use this context and therefore we create
        // an in memory one.
        MagicalRecord.cleanUp()
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
    }
    
    func tearDownCoreData () {
        MagicalRecord.cleanUp()
    }
}
