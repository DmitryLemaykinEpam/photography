//
//  LocationsViewController.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit
import MagicalRecord

class LocationsViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    var distanceToLocation : CLLocation?
    
    var customLocationViewModels = [CustomLocationViewModel]()
    
    var fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadLocations()
    }

    @IBAction func backTap(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func reloadLocations()
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            guard let allCustomLocations = CustomLocation.mr_findAll() as? [CustomLocation] else {
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
            
            guard let fromLocation = self.distanceToLocation else {
                self.didFinishLocationLoading(viewModels: viewModels)
                return
            }
            
            for viewModel in viewModels
            {
                let location = CLLocation(latitude: viewModel.lat!, longitude: viewModel.lon!)
                let distance : CLLocationDistance = location.distance(from: fromLocation)
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

extension LocationsViewController: NSFetchedResultsControllerDelegate
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

extension LocationsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customLocationViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCellReuseId") as? LocationTableViewCell else {
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

extension LocationsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewModel = self.customLocationViewModels[indexPath.row]
        
        let latFormatted = String(format: "%.16f", viewModel.lat!)
        let lonFormatted = String(format: "%.16f", viewModel.lon!)
        
        let predicate = NSPredicate(format: "name = \"\(viewModel.name!)\" AND lat = \(latFormatted) AND lon = \(lonFormatted)")
        
        guard let location = CustomLocation.mr_findFirst(with: predicate) else {
            print("Error: could not find CustomLocation for ViewModel")
            return
        }
        
        let detailsViewController = LocationDetailsViewController.storyboardViewController()
        detailsViewController.location = location
        
        self.present(detailsViewController, animated: true, completion: nil)
    }
}


