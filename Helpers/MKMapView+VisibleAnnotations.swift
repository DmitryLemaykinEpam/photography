//
//  MKMapView+VisibleAnnotations.swift
//  PhotographyStartupTests
//
//  Created by Dmitry Lemaykin on 9/12/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView
{
    func visibleAnnotations() -> [MKAnnotation]
    {
        return annotations(in: visibleMapRect).map { obj -> MKAnnotation in return obj as! MKAnnotation }
    }
}
