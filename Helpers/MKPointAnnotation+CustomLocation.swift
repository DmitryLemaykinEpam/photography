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
    static func createFor(_ locationViewModel: LocationViewModel) -> MKPointAnnotation
    {
        let annotation = MKPointAnnotation()
        annotation.title = locationViewModel.name
        annotation.coordinate = locationViewModel.coordinate
    
        return annotation
    }
}
