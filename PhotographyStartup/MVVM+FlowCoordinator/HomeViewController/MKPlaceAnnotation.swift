//
//  MKPointAnnotation.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/13/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import MapKit

class MKPlaceAnnotation: MKPointAnnotation
{
    var placeId: String?
    
    init(_ placeViewModel: PlaceViewModel)
    {
        self.placeId = placeViewModel.placeId

        super.init()
        
        self.title = placeViewModel.name.value
        self.coordinate = placeViewModel.coordinate
    }
}
