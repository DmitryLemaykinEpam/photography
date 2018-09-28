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
    func isForLocationViewModel(_ locationViewModel: LocationViewModel) -> Bool
    {
        if title == locationViewModel.name &&
           coordinate == locationViewModel.coordinate
        {
            return true
        }
        
        return false
    }
}
