//
//  Moc.swift
//  PhotographyStartupTests
//
//  Created by Dmitry Lemaykin on 9/12/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import XCTest

class VisibleLocationsManagerDelegate_Moc : VisibleLocationsManagerDelegate
{
    var expectation : XCTestExpectation?
    
    var didCall_addCustomLocation = false
    var didCall_removeCustomLocation = false
    var didCall_removeAllCustomLocation = false
    
    var customLocation : CustomLocation?
    
    func addCustomLocation(_ newCustomLocation: CustomLocation) {
        didCall_addCustomLocation = true
        self.customLocation = newCustomLocation
        expectation?.fulfill()
    }
    
    func removeCustomLocation(_ customLocation: CustomLocation) {
        didCall_removeCustomLocation = true
        self.customLocation = customLocation
        expectation?.fulfill()
    }
    
    func removeAllCustomLocation() {
        didCall_removeAllCustomLocation = false
        expectation?.fulfill()
    }
}
