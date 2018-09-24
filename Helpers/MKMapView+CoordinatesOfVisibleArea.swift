//
//  wvvfdw.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView
{
    func getNECoordinate() -> CLLocationCoordinate2D
    {
        let mRect = self.visibleMapRect
        let coordinate = MKMapPoint(x: mRect.maxX, y:mRect.origin.y).coordinate
        return coordinate
    }
    
    func getNWCoordinate() -> CLLocationCoordinate2D
    {
        let mRect = self.visibleMapRect
        let coordinate = MKMapPoint(x: mRect.midX, y:mRect.origin.y).coordinate
        return coordinate
    }
    
    func getSECoordinate() -> CLLocationCoordinate2D
    {
        let mRect = self.visibleMapRect
        let coordinate = MKMapPoint(x: mRect.maxX, y: mRect.maxY).coordinate
        return coordinate
    }

    func getSWCoordinate() -> CLLocationCoordinate2D
    {
        let mRect = self.visibleMapRect
        let coordinate = MKMapPoint(x: mRect.origin.x, y: mRect.maxY).coordinate
        return coordinate
    }
}
