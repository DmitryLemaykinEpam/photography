//
//  AllLocationsCoordinator.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/19/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit

protocol AllLocationsCoordinatorDelegate: class
{
    func allLocationsCoordinatorDidSelectBackAction(_ coordinator: AllLocationsCoordinator)
}

class AllLocationsCoordinator: Coordinator
{    
    weak var delegate : AllLocationsCoordinatorDelegate?
    
    private let presenter: UINavigationController
    
    private let locationsManager: LocationsManager
    private let userLocationManager: UserLocationManager
    
    private var locationDetailsCoordinator: LocationDetailsCoordinator?
    
    init(presenter: UINavigationController, locationsManager: LocationsManager, userLocationManager: UserLocationManager)
    {
        self.presenter = presenter
        self.locationsManager = locationsManager
        self.userLocationManager = userLocationManager
    }
    
    func start()
    {
        showAllLocationViewController()
    }
    
    func showAllLocationViewController()
    {
        let allLocationsViewController = AllLocationsViewController.storyboardViewController()
        allLocationsViewController.viewModel = AllLocationsViewModel(locationsManager: locationsManager, userLocationManager: userLocationManager)
        allLocationsViewController.delegate = self
        
        presenter.pushViewController(allLocationsViewController, animated: true)
    }
    
    func showLocationDetailesViewController(_ locationViewModel: LocationViewModel)
    {
        let locationDetailsCoordinator = LocationDetailsCoordinator(presenter: presenter, locationsManager: locationsManager, selectedLocationViewModel: locationViewModel)
        locationDetailsCoordinator.delegate = self
        locationDetailsCoordinator.start()
        
        self.locationDetailsCoordinator = locationDetailsCoordinator
    }
}

extension AllLocationsCoordinator: AllLocationsViewControllerDelegate
{
    func allLocationsViewControllerDelegateDidSelectLocation(_ locationViewModel: LocationViewModel)
    {
        showLocationDetailesViewController(locationViewModel)
    }
    
    func allLocationsViewControllerDelegateDidBackAction()
    {
        presenter.popViewController(animated: true)
        self.delegate?.allLocationsCoordinatorDidSelectBackAction(self)
    }
}

extension AllLocationsCoordinator: LocationDetailsCoordinatorDelegate
{
    func locationDetailsCoordinatorDidSelectBackAction(_ coordinator: LocationDetailsCoordinator)
    {
        locationDetailsCoordinator = nil
    }
}
