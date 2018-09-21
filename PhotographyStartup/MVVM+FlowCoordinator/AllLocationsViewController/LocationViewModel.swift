//
//  CustomLocationViewModel.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit

protocol LocationViewModelDelegate: class
{
    func locationViewModelDidChange(_ locationViewModel: LocationViewModel)
}

class LocationViewModel
{
    weak var delegate: LocationViewModelDelegate?
    
    var name: String?
    var coordinate: CLLocationCoordinate2D?
    var notes: String?
    var distance: String = ""
}
