//
//  ClosestLocationsViewController.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit

import RxSwift
import RxCocoa

protocol ClosestPlacesViewModelProtocol
{
    func closestPlaceViewModel(index: Int) -> ClosestPlaceCellViewModel?
    var closestPlacesViewModelsChanges: Observable<Change<ClosestPlaceCellViewModel>>{get}
    var closestPlacesCount: Variable<Int?>{get}
    
    func createPlace()
    
    func startTrackingUserLoaction()
    func stopTrackingUserLoaction()
}

protocol AllLocationsViewControllerDelegate: class
{
    func allLocationsViewControllerDelegateDidSelectPlace(_ placeId: String)
    func allLocationsViewControllerDelegateDidBackAction()
}

class ClosestPlacesViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    var placesCount: Int?
    
    private var disposeBag = DisposeBag()
    
    var clocestPlacesVMs: [PlaceViewModel]?
    
    weak var delegate: AllLocationsViewControllerDelegate?
    
    var viewModel: ClosestPlacesViewModelProtocol!
    
    func bindViewModel()
    {
        viewModel.closestPlacesCount.asObservable()
            .map({ (count) -> String in
                
                var countStr = "No Place"
                if let count = count
                {
                    countStr = "\(count)"
                }
                
                return "All Places count: \(countStr)"
            })
            .observeOn(MainScheduler.instance)
            .bind(to: self.navigationItem.rx.title)
            .disposed(by: disposeBag)
            
        viewModel.closestPlacesCount.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (count) in
                if self.placesCount == count
                {
                    // Do nothing
                } else {
                    self.tableView.reloadData()
                }
                
                self.placesCount = count
        })
        .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        
        bindViewModel()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        disposeBag = DisposeBag()
        
        viewModel.stopTrackingUserLoaction()
        
        if isMovingFromParent
        {
            delegate?.allLocationsViewControllerDelegateDidBackAction()
        }
    }
    
    
    @IBAction func createPlaces(_ sender: Any)
    {
        viewModel.createPlace()
    }
}

// MARK: - UITableViewDataSource
extension ClosestPlacesViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let count = self.viewModel.closestPlacesCount.value else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableView.ReuseId.LocationCell) as? ClosestPlaceTableViewCell else {
            return UITableViewCell()
        }
        
        guard let closestPlaceViewModel = self.viewModel.closestPlaceViewModel(index: indexPath.row) else {
            return UITableViewCell()
        }
        cell.bindTo(viewModel: closestPlaceViewModel)
        
        print("cell for: \(indexPath)")
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ClosestPlacesViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let closestPlaceViewModel = viewModel.closestPlaceViewModel(index: indexPath.row) else {
            return
        }
        
        guard let selectedPlaceId = closestPlaceViewModel.placeId else {
            return
        }
        
        self.delegate?.allLocationsViewControllerDelegateDidSelectPlace(selectedPlaceId)
    }
}
