//
//  MKPointAnnotation.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/13/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import MapKit

extension MKPointAnnotation
{
    static func createFor(_ customLocation: Location) -> MKPointAnnotation
    {
        let annotation = MKPointAnnotation()
        annotation.title = customLocation.name
        annotation.coordinate = CLLocationCoordinate2DMake(customLocation.lat, customLocation.lon)
    
        return annotation
    }
}
