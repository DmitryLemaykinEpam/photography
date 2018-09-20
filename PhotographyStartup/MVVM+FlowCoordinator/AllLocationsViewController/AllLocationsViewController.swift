//
//  AllLocationsViewController.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit
import MagicalRecord

protocol AllLocationsViewControllerDelegate : class
{
    func allLocationsViewControllerDelegateDidSelectLocation(_ location: CustomLocationViewModel)
    func allLocationsViewControllerDelegateDidBackAction()
}

class AllLocationsViewController: UIViewController
{
    weak var delegate: AllLocationsViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    var userCoordinate: CLLocationCoordinate2D?
    
    var customLocationViewModels = [CustomLocationViewModel]()
    
    var fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadLocations()
    }

    @IBAction func backTap(_ sender: Any)
    {
        self.delegate?.allLocationsViewControllerDelegateDidBackAction()
    }
    
    func reloadLocations()
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            guard let allCustomLocations = Location.mr_findAll() as? [Location] else {
                self.didFinishLocationLoading(viewModels: nil)
                return
            }
            
            var viewModels = [CustomLocationViewModel]()
            for customLocation in allCustomLocations
            {
                let customLocationViewModel = CustomLocationViewModel()
                customLocationViewModel.name = customLocation.name
                customLocationViewModel.lat = customLocation.lat
                customLocationViewModel.lon = customLocation.lon
                
                viewModels.append(customLocationViewModel)
            }
            
            guard let userCoordinate = self.userCoordinate else {
                self.didFinishLocationLoading(viewModels: viewModels)
                return
            }
            
            let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.latitude)
            
            for viewModel in viewModels
            {
                let location = CLLocation(latitude: viewModel.lat!, longitude: viewModel.lon!)
                let distance = location.distance(from: userLocation)
                viewModel.distance = distance
            }
            
            viewModels.sort(by: { (viewModel1, viewModel2) -> Bool in
                guard let distance1 = viewModel1.distance, let distance2 = viewModel2.distance else {
                    return false
                }
                
                if distance1 < distance2 {
                    return true
                } else {
                    return false
                }
            })
            
            self.didFinishLocationLoading(viewModels: viewModels)
        }
    }
    
    func didFinishLocationLoading(viewModels: [CustomLocationViewModel]?)
    {
        DispatchQueue.main.async {
            guard let viewModels = viewModels else {
                return
            }
            
            self.customLocationViewModels = viewModels
            self.tableView.reloadData()
        }
    }
}

extension AllLocationsViewController: NSFetchedResultsControllerDelegate
{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        self.tableView.beginUpdates();
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type
        {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                return
            }
            
            self.tableView.insertRows(at: [newIndexPath], with: .fade)
            break
        case .delete: break
        case .move: break
        case .update: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}

extension AllLocationsViewController: UITableViewDataSource
{
    struct Constants {
        static let LocationCellReuseId = "LocationCellReuseId"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customLocationViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.LocationCellReuseId) as? LocationTableViewCell else {
            return UITableViewCell()
        }
        
        let viewModel = self.customLocationViewModels[indexPath.row]
        cell.textLabel?.text = viewModel.name

        guard let distance = viewModel.distance else {
            cell.distanceLabel.text = "0"
            return cell
        }
        let distanceFormatter = MKDistanceFormatter()
        let distanceString = distanceFormatter.string(fromDistance: distance)

        cell.distanceLabel.text = distanceString
        return cell
    }
}

extension AllLocationsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewModel = self.customLocationViewModels[indexPath.row]
        
        self.delegate?.allLocationsViewControllerDelegateDidSelectLocation(viewModel)
    }
}


