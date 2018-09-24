//
//  DefaultLocations.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/10/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//
//  TODO: make CustomLocation confirm Codable
//  CustomLocation is NSManagedObject which is NSObject, need more time to dive in
//  Simple structure : Codable is faster approach

import UIKit

struct DefaultLocations: Codable
{
    struct DefaultLocation: Codable {
        let name: String
        let lat: Double
        let lng: Double
    }
    
    let locations: [DefaultLocation]
}
