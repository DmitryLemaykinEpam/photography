//
//  HomeViewController.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/10/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit

protocol HomeViewControllerDelegate: class
{
    func homeViewControllerDidSelectShowAllLocations(_ homeViewController: HomeViewController)
    func homeViewControllerDidSelectEditLocation(_ locationViewModel: LocationViewModel)
}

class HomeViewController: UIViewController
{
    var viewModel: HomeViewModel!

    weak var delegate: HomeViewControllerDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var mapLongTapGestureRecognizer: UILongPressGestureRecognizer!
    
    var selectedLocationViewModel: LocationViewModel?
    
    // These annotations match Location ViewModels from viewModel
    private var annotations = [MKAnnotation]()
    
    struct Constants {
        static let CustomAnnotationReuseId = "customAnnotationReuseId"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.CustomAnnotationReuseId)
        
        bindViewModel()
    }
    
    func bindViewModel()
    {
        viewModel.userCoordinate.bind(to: self) { strongSelf, userCoordinate in
            print("userCoordinate: ", String(describing: userCoordinate))
            
            guard let userCoordinate = userCoordinate else {
                return
            }
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: userCoordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
        
        viewModel.visibleLocationViewModels.observeNext { observableArrayEvent in
            
            switch observableArrayEvent.change
            {
            case .reset:
                print("reset")
                self.annotations.removeAll()
                
            case .inserts(let indexes):
                print("inserts: \(indexes)")
                
                // Avoiding indexe shifting in insert by going from lowest to higest index
                var annotationsToAdd = [MKAnnotation]()
                for indexOfIndex in 0..<indexes.count
                {
                    let index = indexes[indexOfIndex]
                    
                    let locationViewModel = observableArrayEvent.source.array[index]
                    
                    let annotation = MKPointAnnotation.createFor(locationViewModel)
                    
                    self.annotations.insert(annotation, at: index)
                    annotationsToAdd.append(annotation)
                }
                self.mapView.addAnnotations(annotationsToAdd)
                
            case .deletes(let indexes):
                print("deletes: \(indexes)")
                // Avoiding indexe shifting in deletes by going from higest to lowest index
                var annotationsToRemove = [MKAnnotation]()
                for indexOfIndex in (0..<indexes.count).reversed()
                {
                    let index = indexes[indexOfIndex]
                    
                    let annotationToRemove = self.annotations.remove(at: index)
                    annotationsToRemove.append(annotationToRemove)
                }
                self.mapView.removeAnnotations(annotationsToRemove)
                
            case .updates(let indexes):
                print("updates: \(indexes)")
                
                var annotationsToRemove = [MKAnnotation]()
                var annotationsToAdd = [MKAnnotation]()
                for index in indexes
                {
                    let locationViewModel = observableArrayEvent.source.array[index]
                    if self.selectedLocationViewModel == locationViewModel
                    {
                        if locationViewModel.updatedName == nil
                        {
                            continue
                        }
                    }
                    
                    let annotationToRemove = self.annotations.remove(at: index)
                    annotationsToRemove.append(annotationToRemove)
                    
                   
                    let annotationToAdd = MKPointAnnotation.createFor(locationViewModel)
                    
                    self.annotations.insert(annotationToAdd, at: index)
                    annotationsToAdd.append(annotationToAdd)
                }
                self.mapView.removeAnnotations(annotationsToRemove)
                self.mapView.addAnnotations(annotationsToAdd)
                
            case .move(let fromIndex, let toIndex):
                print("move")
                swap(&self.annotations[fromIndex], &self.annotations[toIndex])
            default:
                // case .beginBatchEditing:
                // case .endBatchEditing:
                break
            }
            
        }.dispose(in: bag)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        viewModel.startTarckingUserLoaction()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        viewModel.stopTarckingUserLoaction()
    }
    
    func addAnnotations(_ locationViewModels: [LocationViewModel])
    {
        var annotations = [MKPointAnnotation]()
        for location in locationViewModels
        {
            let annotation = MKPointAnnotation.createFor(location)
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
}

//MARK - User actions
extension HomeViewController
{
    @IBAction func longTapOnMap(_ sender: UILongPressGestureRecognizer)
    {
        // Protection from multiple taps
        if sender.isEnabled == false
        {
            return
        }
        sender.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500)) {
            sender.isEnabled = true
        }
        
        if let selectedLocationViewModel = self.selectedLocationViewModel
        {
            defer {
                self.selectedLocationViewModel = nil
            }
            
            guard let index = viewModel.visibleLocationViewModels.array.index(of:selectedLocationViewModel) else {
                print("Error: Could not get index for selectedLocationViewModel")
                return
            }
            
            let annotation = annotations[index]
            mapView.deselectAnnotation(annotation, animated: true)
            return
        }
        
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        print("Tapped at lat: \(locationCoordinate.latitude) lon: \(locationCoordinate.longitude)")
        
        let newLocationViewModel = viewModel.createNewLocationViewModel()
        newLocationViewModel.updatedCoordinate = locationCoordinate
        
        let _ = newLocationViewModel.saveUpdates()
    }
    
    @IBAction func allLocationsTap(_ sender: Any)
    {
        self.delegate?.homeViewControllerDidSelectShowAllLocations(self)
    }
}

// MARK - MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        let neCoordinate = mapView.getNECoordinate()
        let swCoordinate = mapView.getSWCoordinate()
        
        viewModel.updateVisibleArea(neCoordinate: neCoordinate, swCoordinate: swCoordinate)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation {
            return nil
        }
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier:Constants.CustomAnnotationReuseId) as? MKMarkerAnnotationView else
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
        
        guard let annotation = view.annotation else {
            print("Error: view dont have annotation")
            return
        }
        
        self.selectedLocationViewModel = viewModel.locationViewModelFor(name: annotation.title, coordinate: annotation.coordinate)
        guard let selectedLocationViewModel = self.selectedLocationViewModel else {
            print("Error: could not select location ViewModel")
            return
        }
        
        self.showLocationActionSheet(selectedLocationViewModel, annotationView: view)
    }
    
    func showLocationActionSheet(_ locationViewModel: LocationViewModel, annotationView: MKAnnotationView?)
    {
        let title = "Location Selected"
        
        var message = "What to do with this location?"
        if let locationName = locationViewModel.name
        {
            message.append("\n\(locationName)")
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: { action in
            self.delegate?.homeViewControllerDidSelectEditLocation(locationViewModel)
        })
        alertController.addAction(editAction)
        
        let dafaultAction = UIAlertAction(title: "Move manualy", style: .cancel, handler: nil)
        alertController.addAction(dafaultAction)
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive, handler:{ action in
            self.viewModel.removeLocation(locationViewModel)
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
            
            selectedLocationViewModel.updatedCoordinate = annotation.coordinate
            let _ = selectedLocationViewModel.saveUpdates()
            break
        default:
            // Do nothing
            break
        }
    }
    
    func visibleAnnotationFor(_ locationViewModel: LocationViewModel) -> MKAnnotation?
    {
        let visibleAnnotations = mapView.visibleAnnotations()
        for annotation in visibleAnnotations
        {
            if annotation.isForLocationViewModel(locationViewModel)
            {
                return annotation
            }
        }
        
        return nil
    }
}
