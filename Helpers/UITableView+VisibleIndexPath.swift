//
//  UITableView+VisibleIndexPath.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 1/22/19.
//  Copyright © 2019 Dmitry Lemaykin. All rights reserved.
//

import UIKit

extension UITableView
{
    public func isRowCompletelyVisible(at indexPath: IndexPath) -> Bool
    {
        let rect = rectForRow(at: indexPath)
        return boundsWithoutInset.contains(rect)
    }

    public var boundsWithoutInset: CGRect
    {
        var boundsWithoutInset = bounds
        boundsWithoutInset.origin.y += contentInset.top
        boundsWithoutInset.size.height -= contentInset.top + contentInset.bottom
        return boundsWithoutInset
    }
}
