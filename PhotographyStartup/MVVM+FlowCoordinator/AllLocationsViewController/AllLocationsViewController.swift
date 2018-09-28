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

protocol AllLocationsViewModelProtocol
{
    var locationViewModels: Observable<[LocationViewModel]>{get}
    var userCoordinate: Observable<CLLocationCoordinate2D?>{get}
    
    func fetch()
    func startTrackingUserLoaction()
    func stopTrackingUserLoaction()
}

protocol AllLocationsViewControllerDelegate: class
{
    func allLocationsViewControllerDelegateDidSelectLocation(_ location: LocationViewModel)
    func allLocationsViewControllerDelegateDidBackAction()
}

class AllLocationsViewController: UIViewController
{
    weak var delegate: AllLocationsViewControllerDelegate?
    
    private var _viewModel: AllLocationsViewModelProtocol!
    var viewModel: AllLocationsViewModelProtocol!
    {
        get {
            return _viewModel
        }
        set {
            _viewModel = newValue
            bindViewModel()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let distanceFormatter = MKDistanceFormatter()
    
    func bindViewModel()
    {
        _viewModel.locationViewModels.bind(to: self) { strongSelf, _ in
            guard let tableView = strongSelf.tableView else {
                return
            }
            tableView.reloadData()
        }
        
        _viewModel.userCoordinate.bind(to: self) { strongSelf, coordinate in
            print("Coordinate: ", String(describing: coordinate))
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        viewModel.fetch()
        viewModel.startTrackingUserLoaction()
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        viewModel.stopTrackingUserLoaction()
        
        if isMovingFromParent
        {
            delegate?.allLocationsViewControllerDelegateDidBackAction()
        }
    }
}

// MARK: - UITableViewDataSource
extension AllLocationsViewController: UITableViewDataSource
{
    struct Constants {
        static let LocationCellReuseId = "LocationCellReuseId"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return viewModel.locationViewModels.value.count
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
        var titleAttributedString: NSAttributedString?
        if let name = viewModel.name
        {
            titleAttributedString = NSAttributedString(string: name, attributes:
                [NSAttributedString.Key.foregroundColor: UIColor.black,
                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        } else {
            titleAttributedString = NSAttributedString(string:"Name is not yet set", attributes:
                [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        }
        
        cell.textLabel?.attributedText = titleAttributedString
        cell.distanceLabel.text = distanceFormatter.string(fromDistance: viewModel.distance)
    }
}

// MARK: - UITableViewDelegate
extension AllLocationsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedLocationViewModel = viewModel.locationViewModels.value[indexPath.row]
        
        self.delegate?.allLocationsViewControllerDelegateDidSelectLocation(selectedLocationViewModel)
    }
}
