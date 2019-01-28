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
    
    fileprivate var placesManager = PlacesManager(context: coreDataStack.mainContext)
    fileprivate let userLocationManager = UserLocationManager()
    fileprivate let visiblePlacesManager = VisiblePlacesManager(context: coreDataStack.mainContext)
    
    fileprivate let userLocationSimulator: UserLocationSimulator!
    
    init(window: UIWindow)
    {
        self.window = window
        rootViewController = UINavigationController()

        userLocationSimulator = UserLocationSimulator(userLocationManager: userLocationManager)
        //userLocationSimulator.simulate(GPSFileName: "SydneyRun")
        
        super.init()
        
        rootViewController.delegate = self

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    func start()
    {
        showHomeViewController()
    }
    
    func showHomeViewController()
    {
        let homeCoordinator = HomeCoordinator(presenter: rootViewController, userLocationManager: userLocationManager, visiblePlacesManager: visiblePlacesManager, placesManager: placesManager)
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
