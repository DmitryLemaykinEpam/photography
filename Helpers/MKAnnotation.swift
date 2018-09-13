//
//  MKAnnotation.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/13/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import MapKit

extension MKAnnotation
{
    func forLocation(_ location: CustomLocation) -> Bool
    {
        if self.title == location.name &&
            self.coordinate.latitude == location.lat &&
            self.coordinate.longitude == location.lon
        {
            return true
        }
        
        return false
    }
}
