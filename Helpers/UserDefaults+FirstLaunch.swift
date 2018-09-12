//
//  FirstLaunch.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/10/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit

extension UserDefaults
{
    static let launchedBeforeFlag = "launchedBeforeFlag"
    
    static func firstLaunch() -> Bool
    {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: launchedBeforeFlag)
       
        return isFirstLaunch
    }
    
    static func setNotFirstLaunch()
    {
        UserDefaults.standard.set(true, forKey: launchedBeforeFlag)
        UserDefaults.standard.synchronize()
    }
}
