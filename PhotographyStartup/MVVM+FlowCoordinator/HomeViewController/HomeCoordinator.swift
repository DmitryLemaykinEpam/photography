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
    weak var delegate: HomeCoordinatorDelegate?
    
    private let presenter: UINavigationController
    
    fileprivate let placesManager: PlacesManager
    fileprivate let visiblePlacesManager: VisiblePlacesManager
    fileprivate let userLocationManager: UserLocationManager
    
    private var allLocationsCoordinator: ClosestPlacesCoordinator?
    private var locationDetailsCoordinator: LocationDetailsCoordinator?
    
    init(presenter: UINavigationController, userLocationManager: UserLocationManager, visiblePlacesManager: VisiblePlacesManager, placesManager: PlacesManager)
    {
        self.presenter = presenter
        self.placesManager = placesManager
        self.visiblePlacesManager = visiblePlacesManager
        self.userLocationManager = userLocationManager
    }
    
    func start()
    {
        showHomeViewController()
    }
    
    func showHomeViewController()
    {
        let homeViewModel = HomeViewModel(visiblePlacesManager: visiblePlacesManager, placesManager: placesManager, userLocationManager: userLocationManager)
        
        let homeViewController = HomeViewController.storyboardViewController()
        homeViewController.viewModel = homeViewModel
        homeViewController.delegate = self
        
        presenter.pushViewController(homeViewController, animated: true)
    }
    
    func showAllLocationsViewController()
    {
        let allLocationsCoordinator = ClosestPlacesCoordinator(presenter: presenter, placesManager: placesManager, userLocationManager: userLocationManager)
        allLocationsCoordinator.delegate = self
        allLocationsCoordinator.start()
        
        self.allLocationsCoordinator = allLocationsCoordinator
    }
    
    func showLocationDetailesViewController(_ placeId: String)
    {
        let locationDetailsCoordinator = LocationDetailsCoordinator(presenter: presenter, placesManager: placesManager, placeId: placeId)
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
    
    func homeViewControllerDidSelectEditLocation(_ placeId: String)
    {
        showLocationDetailesViewController(placeId)
    }
}

// MARK: - AllLocationsCoordinatorDelegate
extension HomeCoordinator: AllLocationsCoordinatorDelegate
{
    func allLocationsCoordinatorDidSelectBackAction(_ coordinator: ClosestPlacesCoordinator)
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
