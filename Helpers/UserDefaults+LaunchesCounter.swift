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
    static let kLaunchesCounter = "LaunchesCounter"
    
    static func firstLaunch() -> Bool
    {
        let lounchesCounter = UserDefaults.standard.integer(forKey: kLaunchesCounter)
        
        if lounchesCounter == 1
        {
            return true
        }
        
        return false
    }
    
    static func incrementLaunchesCounter()
    {
        var lounchesCounter = UserDefaults.standard.integer(forKey: kLaunchesCounter)
        
        lounchesCounter += 1
        UserDefaults.standard.set(lounchesCounter, forKey: kLaunchesCounter)
        UserDefaults.standard.synchronize()
    }
}
