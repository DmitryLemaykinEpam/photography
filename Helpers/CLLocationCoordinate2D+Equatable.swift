//
//  CLLocationCoordinate2D+Equatable.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/24/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D: Equatable
{
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool
    {
        if lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
        {
            return true
        }
        return false
    }
}
