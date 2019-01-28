//
//  ClosestPlacesCoordinator.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/19/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit

protocol AllLocationsCoordinatorDelegate: class
{
    func allLocationsCoordinatorDidSelectBackAction(_ coordinator: ClosestPlacesCoordinator)
}

class ClosestPlacesCoordinator: Coordinator
{    
    weak var delegate: AllLocationsCoordinatorDelegate?
    
    private let presenter: UINavigationController
    
    private let placesManager: PlacesManager
    private let userLocationManager: UserLocationManager
    
    private var locationDetailsCoordinator: LocationDetailsCoordinator?
    
    init(presenter: UINavigationController, placesManager: PlacesManager, userLocationManager: UserLocationManager)
    {
        self.presenter = presenter
        self.placesManager = placesManager
        self.userLocationManager = userLocationManager
    }
    
    func start()
    {
        showAllLocationViewController()
    }
    
    func showAllLocationViewController()
    {
        let closestPlacesManager = ClosestPlacesManager(parentContext: self.placesManager.context, userLocationManager: userLocationManager, placesManager: self.placesManager)
        
        let viewModel = ClosestPlacesViewModel(placesManager: placesManager, userLocationManager: userLocationManager, closestPlacesManager: closestPlacesManager)
        
        let closestPlacesViewController = ClosestPlacesViewController.storyboardViewController()
        closestPlacesViewController.viewModel = viewModel
        closestPlacesViewController.delegate = self
        
        presenter.pushViewController(closestPlacesViewController, animated: true)
    }
    
    func showLocationDetailesViewControllerFor(_ placeId: String)
    {
        let locationDetailsCoordinator = LocationDetailsCoordinator(presenter: presenter, placesManager: placesManager, placeId: placeId)
        locationDetailsCoordinator.delegate = self
        locationDetailsCoordinator.start()
        
        self.locationDetailsCoordinator = locationDetailsCoordinator
    }
}

extension ClosestPlacesCoordinator: AllLocationsViewControllerDelegate
{
    func allLocationsViewControllerDelegateDidSelectPlace(_ placeId: String)
    {
        showLocationDetailesViewControllerFor(placeId)
    }
    
    func allLocationsViewControllerDelegateDidBackAction()
    {
        presenter.popViewController(animated: true)
        self.delegate?.allLocationsCoordinatorDidSelectBackAction(self)
    }
}

extension ClosestPlacesCoordinator: LocationDetailsCoordinatorDelegate
{
    func locationDetailsCoordinatorDidSelectBackAction(_ coordinator: LocationDetailsCoordinator)
    {
        locationDetailsCoordinator = nil
    }
}
