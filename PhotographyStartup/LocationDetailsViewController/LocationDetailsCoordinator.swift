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
    
    init(presenter: UINavigationController)
    {
        self.presenter = presenter
    }
    
    func start()
    {
        showLocationDetailsViewController()
    }
    
    func showLocationDetailsViewController()
    {
        let locationDetailsViewController = LocationDetailsViewController.storyboardViewController()
        locationDetailsViewController.delegate = self
        
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
}
