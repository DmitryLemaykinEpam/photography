//
//  HomeCoordinator.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/20/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit

protocol HomeCoordinatorDelegate: class
{
    func homeCoordinatorDidFinish(_ coordinator: HomeCoordinator)
}

class HomeCoordinator: Coordinator
{
    weak var delegate : HomeCoordinatorDelegate?
    
    private let presenter: UINavigationController
    
    fileprivate let locationsManager: LocationsManager
    fileprivate let userLocationManager: UserLocationManager
    
    private var allLocationsCoordinator: AllLocationsCoordinator?
    private var locationDetailsCoordinator: LocationDetailsCoordinator?
    
    init(presenter: UINavigationController, userLocationManager: UserLocationManager, locationsManager: LocationsManager)
    {
        self.presenter = presenter
        self.locationsManager = locationsManager
        self.userLocationManager = userLocationManager
    }
    
    func start()
    {
        showHomeViewController()
    }
    
    func showHomeViewController()
    {
        let homeViewModel = HomeViewModel(locationsManager: locationsManager, userLocationManager: userLocationManager)
        
        let homeViewController = HomeViewController.storyboardViewController()
        homeViewController.viewModel = homeViewModel
        homeViewController.delegate = self
        
        presenter.pushViewController(homeViewController, animated: true)
    }
    
    func showAllLocationsViewController()
    {
        let allLocationsCoordinator = AllLocationsCoordinator(presenter: presenter, locationsManager: locationsManager, userLocationManager: userLocationManager)
        allLocationsCoordinator.delegate = self
        allLocationsCoordinator.start()
        
        self.allLocationsCoordinator = allLocationsCoordinator
    }
    
    func showLocationDetailesViewController(_ locationViewModel: LocationViewModel)
    {
        let locationDetailsCoordinator = LocationDetailsCoordinator(presenter: presenter, locationsManager: locationsManager, selectedLocationViewModel: locationViewModel)
        locationDetailsCoordinator.delegate = self
        locationDetailsCoordinator.start()
    
        self.locationDetailsCoordinator = locationDetailsCoordinator
    }
}

// MARK: - HomeViewControllerDelegate
extension HomeCoordinator: HomeViewControllerDelegate
{
    func homeViewControllerDidSelectShowAllLocations(_ homeViewController: HomeViewController)
    {
        showAllLocationsViewController()
    }
    
    func homeViewControllerDidSelectEditLocation(_ locationViewModel: LocationViewModel)
    {
        showLocationDetailesViewController(locationViewModel)
    }
}

// MARK: - AllLocationsCoordinatorDelegate
extension HomeCoordinator: AllLocationsCoordinatorDelegate
{
    func allLocationsCoordinatorDidSelectBackAction(_ coordinator: AllLocationsCoordinator)
    {
        allLocationsCoordinator = nil
    }
}

// MARK: - AllLocationsCoordinatorDelegate
extension HomeCoordinator: LocationDetailsCoordinatorDelegate
{
    func locationDetailsCoordinatorDidSelectBackAction(_ coordinator: LocationDetailsCoordinator)
    {
        locationDetailsCoordinator = nil
    }
}
