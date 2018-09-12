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
    func getNECoordinate() -> CLLocationCoordinate2D {
        let mRect = self.visibleMapRect
        let coordinate = self.getCoordinateFromMapRectanglePoint(x: MKMapRectGetMaxX(mRect), y:mRect.origin.y)
        return coordinate
    }
    
    func getNWCoordinate() -> CLLocationCoordinate2D {
        let mRect = self.visibleMapRect
        let coordinate = self.getCoordinateFromMapRectanglePoint(x: MKMapRectGetMinX(mRect), y:mRect.origin.y)
        return coordinate
    }
    
    func getSECoordinate() -> CLLocationCoordinate2D {
        let mRect = self.visibleMapRect
        let coordinate = self.getCoordinateFromMapRectanglePoint(x: MKMapRectGetMaxX(mRect), y:MKMapRectGetMaxY(mRect))
        return coordinate
    }

    func getSWCoordinate() -> CLLocationCoordinate2D {
        let mRect = self.visibleMapRect
        let coordinate = self.getCoordinateFromMapRectanglePoint(x: mRect.origin.x, y:MKMapRectGetMaxY(mRect))
        return coordinate
    }
    
    func getCoordinateFromMapRectanglePoint(x: Double, y: Double) -> CLLocationCoordinate2D {
        let mapPoint = MKMapPointMake(x, y)
        let locationCoordinate = MKCoordinateForMapPoint(mapPoint)
        return locationCoordinate
    }
}
