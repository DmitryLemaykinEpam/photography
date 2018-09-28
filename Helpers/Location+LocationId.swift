//
//  Location+LocationId.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/28/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import CoreData

extension Location
{
    func locationId() -> String
    {
        return objectID.uriRepresentation().absoluteString
    }
}
