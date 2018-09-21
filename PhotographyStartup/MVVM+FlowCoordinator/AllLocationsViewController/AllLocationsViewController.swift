//
//  AllLocationsViewController.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit
import Bond

protocol AllLocationsViewControllerDelegate : class
{
    func allLocationsViewControllerDelegateDidSelectLocation(_ location: LocationViewModel)
    func allLocationsViewControllerDelegateDidBackAction()
}

class AllLocationsViewController: UIViewController
{
    var viewModel: AllLocationsViewModel!
    weak var delegate: AllLocationsViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    func bindViewModel()
    {
        viewModel.locationViewModels.bind(to: self) { strongSelf, _ in
            strongSelf.tableView.reloadData()
        }
        
        viewModel.userCoordinate.bind(to: self) { strongSelf, coordinate in
            print("Coordinate: ", String(describing: coordinate))
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        viewModel.fetch()
        viewModel?.startTrackingUserLoaction()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        viewModel.fetch()
        viewModel?.stopTrackingUserLoaction()
    }
}

// MARK: - User Actions
extension AllLocationsViewController
{
    @IBAction func backTap(_ sender: Any)
    {
        self.delegate?.allLocationsViewControllerDelegateDidBackAction()
    }
}

extension AllLocationsViewController: UITableViewDataSource
{
    struct Constants {
        static let LocationCellReuseId = "LocationCellReuseId"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.viewModel.locationViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.LocationCellReuseId) as? LocationTableViewCell else {
            return UITableViewCell()
        }
        
        let locationViewModel = viewModel.locationViewModels.value[indexPath.row]
  
        cunfigureCellWithViewModel(cell, viewModel: locationViewModel)
        
        return cell
    }
    
    func cunfigureCellWithViewModel(_ cell: LocationTableViewCell, viewModel: LocationViewModel)
    {
        cell.textLabel?.text    = viewModel.name
        cell.distanceLabel.text = viewModel.distance
        
        viewModel.delegate = cell
    }
}

extension AllLocationsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewModel = self.viewModel.locationViewModels.value[indexPath.row]
        
        self.delegate?.allLocationsViewControllerDelegateDidSelectLocation(viewModel)
    }
}


