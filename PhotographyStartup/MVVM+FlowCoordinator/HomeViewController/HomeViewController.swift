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
    func homeViewControllerDidSelectAllLocation(_ homeViewController: HomeViewController)
    func homeViewControllerDidSelectEditLocation(_ location: Location)
}

class HomeViewController: UIViewController
{
    var viewModel: HomeViewModel!

    weak var delegate: HomeViewControllerDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var mapLongTapGestureRecognizer: UILongPressGestureRecognizer!
    
    var selectedLocation: Location?
    
    struct Constants {
        static let CustomAnnotationReuseId = "customAnnotationReuseId"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.CustomAnnotationReuseId)
        //mapView.zoom(toCenterCoordinate: viewModel.userCoordinate, zoomLevel: 10)
        
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
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        viewModel?.startTarckingUserLoaction()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        //viewModel?.stopTarckingUserLoaction()
    }
    
    func addAnnotationsForLocations(_ locations : [Location])
    {
        var annotations = [MKPointAnnotation]()
        for location in locations
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
        if sender.isEnabled == false
        {
            return
        }
        sender.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500)) {
            sender.isEnabled = true
        }
        
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        print("Tapped at lat: \(locationCoordinate.latitude) lon: \(locationCoordinate.longitude)")
        
        guard let newLocation = viewModel?.createNewLocation() else {
            print("Error: could not create location")
            return
        }
        
        newLocation.name = "Name is Not Set"
        newLocation.lat = locationCoordinate.latitude
        newLocation.lon = locationCoordinate.longitude
        
        viewModel?.updateLocationCoordinate(newLocation, newCoordinate: locationCoordinate)
    }
    
    @IBAction func allLocationsTap(_ sender: Any)
    {
        self.delegate?.homeViewControllerDidSelectAllLocation(self)
    }
}

// MARK - MKMapViewDelegate
extension HomeViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        let neCoordinate = mapView.getNECoordinate()
        let swCoordinate = mapView.getSWCoordinate()
        
        viewModel?.updateVisibleArea(neCoordinate: neCoordinate, swCoordinate: swCoordinate)
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
        
        guard let annotation = view.annotation else {
            print("Error: view dont have annotation")
            return
        }
        
        self.selectedLocation = viewModel?.locationFor(annotation.coordinate)
        guard let selectedLocation = self.selectedLocation else {
            print("Error: don't have selected location")
            return
        }
        
        self.showLocationActionSheet(location: selectedLocation, annotationView: view)
    }
    
    func showLocationActionSheet(location: Location, annotationView: MKAnnotationView?)
    {
        let title = "What to do with this location?"
        let message = "Edit location: \(String(describing: location.name))?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: { action in
            self.delegate?.homeViewControllerDidSelectEditLocation(location)
        })
        alertController.addAction(editAction)
        
        let dafaultAction = UIAlertAction(title: "Move manualy", style: .default, handler: nil)
        alertController.addAction(dafaultAction)
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive, handler:{ action in
            self.viewModel?.removeLocation(location)
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
            guard let selectedLocation = self.selectedLocation else {
                print("Error: No selected location to change")
                return
            }
            
            viewModel?.updateLocationCoordinate(selectedLocation, newCoordinate:annotation.coordinate)
            break
        default:
            // Do nothing
            break
        }
    }
}

extension HomeViewController: HomeViewModelDelegate
{
    func locationAdded(_ location: Location)
    {
        addAnnotationsForLocations([location])
    }
 
    func locationRemoved(_ location: Location)
    {
        let visibleAnnotations = mapView.visibleAnnotations()
        
        for annotation in visibleAnnotations
        {
            if annotation.forLocation(location)
            {
                mapView.removeAnnotation(annotation)
                break
            }
        }
    }
    
    func locationUpdated(_ location: Location, oldCoordinate: CLLocationCoordinate2D, newCoordinate: CLLocationCoordinate2D)
    {
        // Do nothing, annotation should be already updated
    }

    func locationsReloaded()
    {
        guard let visibleLocations = self.viewModel?.visibleLocations(), visibleLocations.count != 0 else {
            mapView.removeAnnotations(mapView.annotations)
            return
        }
        
        // Will try to reuse as much existed annotations as possible,
        // this optimisation provide faster reload of annotations when user movign map
        var annotationsToRemove = mapView.annotations
        var locationsToPresent = [Location]()
        
        for location in visibleLocations
        {
            var selectedAnnotationIndex : Int?
            for annotationIndex in 0..<annotationsToRemove.count
            {
                let annotation = annotationsToRemove[annotationIndex]
                
                if annotation.forLocation(location)
                {
                    selectedAnnotationIndex = annotationIndex
                    break
                }
            }
            
            guard let annotationIndex = selectedAnnotationIndex else {
                locationsToPresent.append(location)
                continue
            }
            
            annotationsToRemove.remove(at: annotationIndex)
        }
        mapView.removeAnnotations(annotationsToRemove)
        
        addAnnotationsForLocations(locationsToPresent)
    }
    
//    func userDidChangeCoordinate(_ newUserCoordinate: CLLocationCoordinate2D)
//    {
//        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        let region = MKCoordinateRegion(center: newUserCoordinate, span: span)
//        mapView.setRegion(region, animated: true)
//    }
}

