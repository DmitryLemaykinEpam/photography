//
//  Array.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/13/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import Foundation

extension Array where Element: Equatable
{
    mutating func remove(_ obj: Element)
    {
        self = self.filter { $0 != obj }
    }
}