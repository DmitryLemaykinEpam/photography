//
//  HomeViewController.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/10/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit
import MagicalRecord

protocol HomeViewControllerDelegate: class
{
    func homeViewControllerDidSelectAllLocation(_ homeViewController: HomeViewController)
}

class HomeViewController: UIViewController
{
    weak var delegate : HomeViewControllerDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var mapLongTapGestureRecognizer: UILongPressGestureRecognizer!
    
    var locationsManager : LocationsManager?
    var userLocationManager : UserLoactionManager?

    var selectedLocation : CustomLocation?
    
    struct Constants {
        static let CustomAnnotationReuseId = "customAnnotationReuseId"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier:   Constants.CustomAnnotationReuseId)
        mapView.zoom(toCenterCoordinate: LocationsManager.Sydney, zoomLevel: 10)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        userLocationManager?.startTarckingUserLoaction()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        userLocationManager?.stopTarckingUserLoaction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationsManager?.fetch()
    }
    
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
        
        guard let newCustomeLocation = locationsManager?.createNewCustomLocation() else {
            print("Error: could not create location")
            return
        }
        
        newCustomeLocation.name = "Name is Not Set"
        newCustomeLocation.lat = locationCoordinate.latitude
        newCustomeLocation.lon = locationCoordinate.longitude
        
        locationsManager?.saveToPersistentStore()
    }
    
    @IBAction func allLocationsTap(_ sender: Any)
    {
        self.delegate?.homeViewControllerDidSelectAllLocation(self)
    }
}

extension HomeViewController
{
    func addAnnotationForCustomLocation(_ customLocation : CustomLocation)
    {
        let annotation = MKPointAnnotation.createFor(customLocation)
        mapView.addAnnotation(annotation)
    }
    
    func addAnnotationsForCustomLocations(_ customLocations : [CustomLocation])
    {
        var annotations = [MKPointAnnotation]()
        for customLocation in customLocations
        {
            let annotation = MKPointAnnotation.createFor(customLocation)
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
}

extension HomeViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        let neCoordinate = mapView.getNECoordinate()
        let swCoordinate = mapView.getSWCoordinate()
        
        locationsManager?.updateVisibleArea(neCoordinate: neCoordinate, swCoordinate: swCoordinate)
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
        print("apView: didSelect")
        
        guard let annotation = view.annotation else {
            print("Error: view dont have annotation")
            return
        }
        
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        
        self.selectedLocation = locationsManager?.customLocationFor(lat: lat, lon: lon)
        guard let selectedLocation = self.selectedLocation else {
            print("Error: don't have selected location")
            return
        }
        
        self.showLocationActionSheet(customeLocation: selectedLocation, annotationView: view)
    }
    
    func showLocationActionSheet(customeLocation: CustomLocation, annotationView: MKAnnotationView?)
    {
        let title = "What to do with this location?"
        let message = "Edit location: \(String(describing: customeLocation.name))?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: { action in
            let detailsViewController = LocationDetailsViewController.storyboardViewController()
            detailsViewController.location = customeLocation
            
            self.present(detailsViewController, animated: true, completion: nil)
        })
        alertController.addAction(editAction)
        
        let dafaultAction = UIAlertAction(title: "Move manualy", style: .default, handler: nil)
        alertController.addAction(dafaultAction)
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive, handler:{ action in
            self.locationsManager?.removeCustomeLocation(lat: customeLocation.lat, lon: customeLocation.lon)
            self.locationsManager?.saveToPersistentStore()
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState)
    {
        guard let annotation = view.annotation else {
            print("Error: view dont have annotation")
            return
        }
        
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        
        switch newState
        {
        case .ending:
            guard let selectedLocation = self.selectedLocation else {
                print("Error: No selected location to change")
                return
            }
            
            selectedLocation.lat = lat
            selectedLocation.lon = lon
            
            locationsManager?.saveToPersistentStore()
            break
        default:
            // Do nothing
            break
        }
    }
}


extension HomeViewController : VisibleLocationsManagerDelegate
{
    func addCustomLocation(_ newCustomLocation: CustomLocation)
    {
        addAnnotationForCustomLocation(newCustomLocation)
    }
    
    func removeCustomLocation(_ customLocation: CustomLocation)
    {
        let visibleAnnotations = mapView.visibleAnnotations()
        
        for annotation in visibleAnnotations
        {
            if annotation.forLocation(customLocation)
            {
                mapView.removeAnnotation(annotation)
                break
            }
        }
    }
    
    func reloadAllCustomLocation()
    {
        guard let allVisibleLocations = locationsManager?.allVisibleLocations() else {
            mapView.removeAnnotations(mapView.annotations)
            return
        }
        
        var annotationsToRemove = mapView.annotations
        var locationsToPresent = [CustomLocation]()
        
        for location in allVisibleLocations
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
        
        addAnnotationsForCustomLocations(locationsToPresent)
    }
}

extension HomeViewController : UserLoactionManagerDelegate
{
    func userDidChangeCoordinate(_ newUserCoordinate: CLLocationCoordinate2D)
    {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: newUserCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

