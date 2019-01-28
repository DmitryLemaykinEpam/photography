//
//  Array+Move.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 1/17/19.
//  Copyright © 2019 Dmitry Lemaykin. All rights reserved.
//
// Inspiered by: https://stackoverflow.com/questions/36541764/how-to-rearrange-item-of-an-array-to-new-position-in-swift/36541860

import Foundation

extension Array
{
    mutating func move(fromIndex: Int, toIndex: Int)
    {
        var arr = self
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        
        self = arr
    }
}
