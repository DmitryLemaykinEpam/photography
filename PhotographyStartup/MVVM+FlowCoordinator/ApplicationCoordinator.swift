//
//  ApplicationCoordinator.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/19/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit

class ApplicationCoordinator: NSObject, Coordinator
{
    let window: UIWindow
    fileprivate let rootViewController: UINavigationController
    
    fileprivate var homeCoordinator: HomeCoordinator?
    
    fileprivate var locationsManager = LocationsManager()
    fileprivate let userLocationManager = UserLocationManager()
    
    init(window: UIWindow)
    {
        self.window = window
        rootViewController = UINavigationController()
        
        super.init()
        
        rootViewController.delegate = self
        //rootViewController.navigationBar.isHidden = true
        
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    func start()
    {
        showHomeViewController()
    }
    
    func showHomeViewController()
    {
        let homeCoordinator = HomeCoordinator(presenter: rootViewController, userLocationManager: userLocationManager, locationsManager: locationsManager)
        homeCoordinator.delegate = self
        homeCoordinator.start()
        
        self.homeCoordinator = homeCoordinator
    }
}

//MARK: - UINavigationControllerDelegate
extension ApplicationCoordinator: UINavigationControllerDelegate {}

// MARK: - HomeCoordinatorDelegate
extension ApplicationCoordinator: HomeCoordinatorDelegate
{
    func homeCoordinatorDidFinish(_ coordinator: HomeCoordinator)
    {
        homeCoordinator = nil
    }
}
