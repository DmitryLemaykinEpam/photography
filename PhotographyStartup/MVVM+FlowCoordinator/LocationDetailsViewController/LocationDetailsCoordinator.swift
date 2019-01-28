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
    fileprivate let placesManager: PlacesManager
    
    private var placeId: String
    
    init(presenter: UINavigationController, placesManager: PlacesManager, placeId: String)
    {
        self.presenter = presenter
        self.placesManager = placesManager
        self.placeId = placeId
    }
    
    func start()
    {
        showLocationDetailsViewController()
    }
    
    func showLocationDetailsViewController()
    {
        let locationDetailsViewController = LocationDetailsViewController.storyboardViewController()
        locationDetailsViewController.delegate = self
        
        let place = self.placesManager.placeFor(placeId: self.placeId)
        let placeVM = PlaceViewModel(placesManager: self.placesManager)
        placeVM.place = place
        
        locationDetailsViewController.viewModel = placeVM
        
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
