//
//  HomeViewController.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/10/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit

import RxSwift
import RxCocoa
import RxGesture

protocol HomeViewModelProtocol
{
    var userCoordinate: Observable<CLLocationCoordinate2D?> {get}
    var visiblePlacesViewModelsChanges: Observable<Change<PlaceViewModel>>{get}
    var visiblePlacesCount: Variable<Int?> {get}
    func visiblePlace(index: Int) -> PlaceViewModel?
    
    func startTarckingUserLoaction()
    func stopTarckingUserLoaction()
    
    func createLocationViewModel() -> PlaceViewModel?
    func updateVisibleArea(neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D)
    func placeViewModelFor(placeId: String?) -> PlaceViewModel?
    func removePlace(_ placeId: String)
}

protocol HomeViewControllerDelegate: class
{
    func homeViewControllerDidSelectShowAllLocations(_ homeViewController: HomeViewController)
    func homeViewControllerDidSelectEditLocation(_ placeId: String)
}

class HomeViewController: UIViewController
{
    var viewModel: HomeViewModelProtocol!

    weak var delegate: HomeViewControllerDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var allLocationsButton: UIButton!
    
    var selectedLocationViewModel: PlaceViewModel?
    private var visiblePlacesViewModels: [PlaceViewModel]?
    
    // These annotations match Location ViewModels from viewModel
    private var annotations = [MKAnnotation]()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapView.ReuseId.CustomAnnotation)
        
        mapView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] sender in
                print("mapView tapped")
                
                guard let self = self else {
                    return
                }
                
                if let selectedLocationViewModel = self.selectedLocationViewModel
                {
                    defer {
                        self.selectedLocationViewModel = nil
                    }
                    
                    guard let index = self.visiblePlacesViewModels?.index(of:selectedLocationViewModel) else {
                        print("Error: Could not get index for selectedLocationViewModel")
                        return
                    }
                    
                    let annotation = self.annotations[index]
                    self.mapView.deselectAnnotation(annotation, animated: true)
                    return
                }
                
                let touchLocation = sender.location(in: self.mapView)
                let locationCoordinate = self.mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
                
                print("Tapped at lat: \(locationCoordinate.latitude) lon: \(locationCoordinate.longitude)")
                
                guard let newLocationViewModel = self.viewModel.createLocationViewModel() else {
                    print("Error: could not get newLocationViewModel")
                    return
                }
                newLocationViewModel.coordinate = locationCoordinate
                newLocationViewModel.save()
            })
            .disposed(by: disposeBag)
        
        allLocationsButton.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {
                    return
                }
                
                self.delegate?.homeViewControllerDidSelectShowAllLocations(self)
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModel()
    {
        viewModel.userCoordinate
            .subscribe(onNext: { userCoordinate in
                guard let userCoordinate = userCoordinate,
                      let mapView = self.mapView else {
                    return
                }
                
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: userCoordinate, span: span)
                mapView.setRegion(region, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.visiblePlacesCount.asObservable().subscribe(onNext: { [weak self] count in
            guard let self = self else {
                return
            }
            
            guard let count = count else {
                return
            }
            
            if count > 100 {
                return
            }
            // Optimized in order #notToBlink
            for index in 0..<count
            {
                guard let placeVM = self.viewModel.visiblePlace(index: index) else {
                    continue
                }
                
                if let _ = self.displeydPlaceAnnotationFor(placeVM, in: self.mapView.annotations)
                {
                    // Nothing to do: annotation is displaeyd for placeVM
                } else {
                    let annotation = MKPlaceAnnotation(placeVM)
                    self.mapView.addAnnotation(annotation)
                }
            }
        }).disposed(by: disposeBag)
        
        viewModel.visiblePlacesViewModelsChanges.subscribe(onNext: { change in
            DispatchQueue.main.async {
                
                let existedAnnotations = self.mapView.annotations as! [MKPlaceAnnotation]
                
                switch change.action
                {
                case .insert(_):
                    let annotation = MKPlaceAnnotation(change.anObject)
                    self.mapView.addAnnotation(annotation)
                    
                case .delete(_):
                    guard let placeAnnoationToRemove = self.displeydPlaceAnnotationFor(change.anObject, in: existedAnnotations) else {
                        return
                    }
                    self.mapView.removeAnnotation(placeAnnoationToRemove)
                    
                case .update(_):
                    if let placeAnnoationToUpdate = self.displeydPlaceAnnotationFor(change.anObject, in: existedAnnotations) {
                        self.mapView.removeAnnotation(placeAnnoationToUpdate)
                    }
                    
                    let annotation = MKPlaceAnnotation(change.anObject)
                    self.mapView.addAnnotation(annotation)
                    
                case .move(_, _):
                    if let placeAnnoationToUpdate = self.displeydPlaceAnnotationFor(change.anObject, in: existedAnnotations) {
                        self.mapView.removeAnnotation(placeAnnoationToUpdate)
                    }
                    
                    let annotation = MKPlaceAnnotation(change.anObject)
                    self.mapView.addAnnotation(annotation)
                }
            }
        }).disposed(by: disposeBag)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        if let annotationsCount = viewModel.visiblePlacesCount.value
        {
            for index in 0..<annotationsCount
            {
                guard let placeVM = viewModel.visiblePlace(index: index) else {
                    continue
                }
                
                let annotation = MKPlaceAnnotation(placeVM)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func displeydPlaceAnnotationFor(_ placeVM: PlaceViewModel, in annotations: [MKAnnotation]) -> MKPlaceAnnotation?
    {
        guard let annotation = annotations.first(where: { (annotation) -> Bool in
            if let placeAnnotation = annotation as? MKPlaceAnnotation
            {
                return placeVM.placeId == placeAnnotation.placeId
            }
        
            return false
        }) as? MKPlaceAnnotation else {
            return nil
        }
        
        return annotation
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        viewModel.startTarckingUserLoaction()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        disposeBag = DisposeBag()
    }
    
    func addAnnotations(_ locationViewModels: [PlaceViewModel])
    {
        var annotations = [MKPointAnnotation]()
        for location in locationViewModels
        {
            let annotation = MKPlaceAnnotation(location)
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
}

// MARK - MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        let neCoordinate = mapView.getNECoordinate()
        let swCoordinate = mapView.getSWCoordinate()
        
        // Optimized in order #notToBlink
        DispatchQueue.main.async {
            for existingAnnotation in mapView.annotations
            {
                guard let existingPlaceAnnotation = existingAnnotation as? MKPlaceAnnotation else {
                    continue
                }
                
                if  existingPlaceAnnotation.coordinate.latitude  <= neCoordinate.latitude &&
                    existingPlaceAnnotation.coordinate.latitude  >= swCoordinate.latitude &&
                    
                    existingPlaceAnnotation.coordinate.longitude <= neCoordinate.longitude &&
                    existingPlaceAnnotation.coordinate.longitude >= swCoordinate.longitude
                {
                    // Nothing to do: annotation is visible
                } else {
                    mapView.removeAnnotation(existingAnnotation)
                }
            }
        }

        viewModel.updateVisibleArea(neCoordinate: neCoordinate, swCoordinate: swCoordinate)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation {
            return nil
        }
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier:MKMapView.ReuseId.CustomAnnotation) as? MKMarkerAnnotationView else
        {
            return nil
        }
        
        annotationView.annotation = annotation
        annotationView.isDraggable = true
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        print("MapView: didSelect")
        if view.annotation is MKUserLocation {
            return
        }
        
        guard let annotation = view.annotation as? MKPlaceAnnotation else {
            print("Error: view dont have annotation")
            return
        }
        
        self.selectedLocationViewModel = viewModel.placeViewModelFor(placeId: annotation.placeId)
        guard let selectedLocationViewModel = self.selectedLocationViewModel else {
            print("Error: could not select location ViewModel")
            return
        }
        
        self.showLocationActionSheet(selectedLocationViewModel, annotationView: view)
    }
    
    func showLocationActionSheet(_ locationViewModel: PlaceViewModel, annotationView: MKAnnotationView?)
    {
        let title = "Location Selected"
        
        let message = "What to do with this location?\n\(locationViewModel.name)"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: { action in
            guard let placeId = locationViewModel.placeId else {
                return
            }
            self.delegate?.homeViewControllerDidSelectEditLocation(placeId)
        })
        alertController.addAction(editAction)
        
        let dafaultAction = UIAlertAction(title: "Move manualy", style: .cancel, handler: nil)
        alertController.addAction(dafaultAction)
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive, handler:{ action in
            guard let placeId = locationViewModel.placeId else {
                print("ERROR: could not remove place with no place id")
                return
            }
            
            self.viewModel.removePlace(placeId)
        })
        alertController.addAction(removeAction)
        
        if let popoverController = alertController.popoverPresentationController {
            guard let annotationView = annotationView else {
                print("Error: annotationView is needed to show alertController")
                return
            }
            
            popoverController.sourceView = annotationView
            popoverController.sourceRect = CGRect(x: annotationView.bounds.midX, y: annotationView.bounds.maxY, width: 0, height: 0)
        }
        
        self.present(alertController, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState)
    {
        guard let annotation = view.annotation else {
            print("Error: view dont have annotation")
            return
        }
        
        switch newState
        {
        case .ending:
            guard let selectedLocationViewModel = self.selectedLocationViewModel else {
                print("Error: No selected location to change")
                return
            }
            
            selectedLocationViewModel.coordinate = annotation.coordinate
            selectedLocationViewModel.save()
       
        default:
            // Do nothing
            break
        }
    }
}
