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
    func locationDetailsCoordinatorCoordinatorDidSelectBackAction(_ coordinator: LocationDetailsCoordinator)
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
        presenter.popViewController(animated: true)
        self.delegate?.locationDetailsCoordinatorCoordinatorDidSelectBackAction(self)
    }
    
    func locationDetailsViewControllerDidSaveViewModel(_ viewModel: LocationViewModel)
    {
        locationsManager.fetch()
        
        guard let location = locationsManager.locationFor(name: viewModel.name, coordinate: viewModel.coordinate) else {
            print("Error: did not have location for viewModel")
            return
        }
        
        if let updatedName = viewModel.updatedName {
            location.name = updatedName
        }
        
        if let updatedNotes = viewModel.updatedNotes {
            location.notes = updatedNotes
        }
        
        if let updatedCoordinate = viewModel.updatedCoordinate {
            location.lat = updatedCoordinate.latitude
            location.lon = updatedCoordinate.longitude
        }
        
        locationsManager.saveToPersistentStore()
//        NSManagedObjectContext.mr_default().mr_saveToPersistentStore { (success, error) in
//            self.showSaveResultAlert(success: success, error: error)
//        }
    }
}
