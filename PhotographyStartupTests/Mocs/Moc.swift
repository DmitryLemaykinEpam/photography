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
    var expectation : XCTestExpectation?
    
    var didCall_addCustomLocation = false
    var didCall_removeCustomLocation = false
    var didCall_reloadAllCustomLocation = false
    
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
    
    func reloadAllCustomLocation() {
        didCall_reloadAllCustomLocation = false
        expectation?.fulfill()
    }
}
