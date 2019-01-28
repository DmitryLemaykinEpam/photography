//
//  wvvfdw.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import MapKit

extension MKMapView
{
    func getNECoordinate() -> CLLocationCoordinate2D
    {
        let coordinate = MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.origin.y).coordinate
        return coordinate
    }
    
    func getNWCoordinate() -> CLLocationCoordinate2D
    {
        let coordinate = MKMapPoint(x: visibleMapRect.midX, y: visibleMapRect.origin.y).coordinate
        return coordinate
    }
    
    func getSECoordinate() -> CLLocationCoordinate2D
    {
        let coordinate = MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.maxY).coordinate
        return coordinate
    }

    func getSWCoordinate() -> CLLocationCoordinate2D
    {
        let coordinate = MKMapPoint(x: visibleMapRect.origin.x, y: visibleMapRect.maxY).coordinate
        return coordinate
    }
}
