//
//  File.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 1/18/19.
//  Copyright © 2019 Dmitry Lemaykin. All rights reserved.
//

import Foundation

protocol PlacesManagerDelegate
{
    func placeAdded(_ newPlace: Place)
    func placeUpdated(_ updatedPlace: Place, indexPath: IndexPath?)
    func placeRemoved(_ removedPlace: Place)
    func placesReloaded()
}
