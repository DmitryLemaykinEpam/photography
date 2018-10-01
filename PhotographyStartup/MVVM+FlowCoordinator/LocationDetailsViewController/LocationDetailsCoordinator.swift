//
//  LocationDetailsCoordinator.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/20/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit

protocol LocationDetailsCoordinatorDelegate: class
{
    func locationDetailsCoordinatorDidSelectBackAction(_ coordinator: LocationDetailsCoordinator)
}

class LocationDetailsCoordinator: Coordinator
{
    weak var delegate: LocationDetailsCoordinatorDelegate?
    
    private let presenter: UINavigationController
    fileprivate let locationsManager: LocationsManager
    
    private var locationViewModel: LocationViewModel
    
    init(presenter: UINavigationController, locationsManager: LocationsManager, selectedLocationViewModel: LocationViewModel)
    {
        self.presenter = presenter
        self.locationsManager = locationsManager
        self.locationViewModel = selectedLocationViewModel
    }
    
    func start()
    {
        showLocationDetailsViewController()
    }
    
    func showLocationDetailsViewController()
    {
        let locationDetailsViewController = LocationDetailsViewController.storyboardViewController()
        locationDetailsViewController.delegate = self
        locationDetailsViewController.viewModel = self.locationViewModel
        
        presenter.pushViewController(locationDetailsViewController, animated: true)
    }
}

extension LocationDetailsCoordinator: LocationDetailsViewControllerDelegate
{
    func locationDetailsViewControllerDidBackAction()
    {
        self.delegate?.locationDetailsCoordinatorDidSelectBackAction(self)
    }
}
