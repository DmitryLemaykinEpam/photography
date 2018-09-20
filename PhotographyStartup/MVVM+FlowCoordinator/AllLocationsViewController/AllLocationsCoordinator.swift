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
    
    private let allLocationsManager: LocationsManager
    private let userLocationManager: UserLocationManager
    
    private var locationDetailsCoordinator: LocationDetailsCoordinator?
    
    init(presenter: UINavigationController, userLocationManager: UserLocationManager)
    {
        self.presenter = presenter
        self.allLocationsManager = LocationsManager()
        self.userLocationManager = userLocationManager
    }
    
    func start()
    {
        showAllLocationViewController()
    }
    
    func showAllLocationViewController()
    {
        let allLocationsViewController = AllLocationsViewController.storyboardViewController()
        allLocationsViewController.delegate = self
        allLocationsViewController.userCoordinate = userLocationManager.userCoordinate()
        
        presenter.pushViewController(allLocationsViewController, animated: true)
    }
    
    func showLocationDetailesViewController(_ location: Location)
    {
        let locationDetailsCoordinator = LocationDetailsCoordinator(presenter: presenter)
        locationDetailsCoordinator.delegate = self
        locationDetailsCoordinator.start()
        
        self.locationDetailsCoordinator = locationDetailsCoordinator
    }
}

extension AllLocationsCoordinator: AllLocationsViewControllerDelegate
{
    func allLocationsViewControllerDelegateDidSelectLocation(_ viewModel: CustomLocationViewModel)
    {
        let latFormatted = String(format: "%.16f", viewModel.lat!)
        let lonFormatted = String(format: "%.16f", viewModel.lon!)
        
        let predicate = NSPredicate(format: "name = \"\(viewModel.name!)\" AND lat = \(latFormatted) AND lon = \(lonFormatted)")
        
        guard let location = Location.mr_findFirst(with: predicate) else {
            print("Error: could not find CustomLocation for ViewModel")
            return
        }
        
        showLocationDetailesViewController(location)
    }
    
    func allLocationsViewControllerDelegateDidBackAction()
    {
        presenter.popViewController(animated: true)
        self.delegate?.allLocationsCoordinatorDidSelectBackAction(self)
    }
}

extension AllLocationsCoordinator: LocationDetailsCoordinatorDelegate
{
    func locationDetailsCoordinatorCoordinatorDidSelectBackAction(_ coordinator: LocationDetailsCoordinator)
    {
        locationDetailsCoordinator = nil
    }
}
