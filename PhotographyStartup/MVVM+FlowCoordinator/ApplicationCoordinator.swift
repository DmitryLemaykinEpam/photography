//
//  ApplicationCoordinator.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/19/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit

class ApplicationCoordinator: Coordinator
{
    let window: UIWindow
    fileprivate let rootViewController: UINavigationController
    
    fileprivate var homeViewController: HomeViewController?
    
    fileprivate var childCoordinators = [Coordinator]()
    
    fileprivate var locationsManager = LocationsManager()
    fileprivate let userLoactionManager = UserLoactionManager()
    
    init(window: UIWindow)
    {
        self.window = window
        
        rootViewController = UINavigationController()
        rootViewController.navigationBar.isHidden = true
        
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    func start()
    {
        showHomeViewController()
    }
    
    func showHomeViewController()
    {
        let homeViewController = HomeViewController.storyboardViewController()
        homeViewController.locationsManager = self.locationsManager       
        homeViewController.delegate = self
        
        self.locationsManager.delegate = homeViewController
        
        rootViewController.pushViewController(homeViewController, animated: true)
        
        self.homeViewController = homeViewController
    }
    
    func showAllLocationsViewController()
    {
        let allLocationsCoordinator = AllLocationsCoordinator(presenter: rootViewController, userLoactionManager: userLoactionManager)
        allLocationsCoordinator.delegate = self
        allLocationsCoordinator.start()
        childCoordinators.append(allLocationsCoordinator)
    }
    
    func dismissChildCoordinator(_ coordinator: Coordinator)
    {
        // TODO remove exectly coordinator
        childCoordinators.removeFirst()
    }
}

// MARK: - HomeViewControllerDelegate
extension ApplicationCoordinator: HomeViewControllerDelegate
{
    func homeViewControllerDidSelectAllLocation(_ homeViewController: HomeViewController)
    {
        showAllLocationsViewController()
    }
}

// MARK: - AllLocationsCoordinatorDelegate
extension ApplicationCoordinator: AllLocationsCoordinatorDelegate
{
    func allLocationsCoordinatorDidSelectBackAction(_ coordinator: AllLocationsCoordinator)
    {
        dismissChildCoordinator(coordinator)
    }
}
