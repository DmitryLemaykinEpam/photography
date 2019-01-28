//
//  ItemChange.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 1/18/19.
//  Copyright © 2019 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import RxSwift

struct Change<T>
{
    let anObject: T
    let action: Action
}

enum Action
{
    case insert(indexPath: IndexPath)
    case delete(indexPath: IndexPath)
    case update(indexPath: IndexPath)
    case move(from: IndexPath, to: IndexPath)
}
