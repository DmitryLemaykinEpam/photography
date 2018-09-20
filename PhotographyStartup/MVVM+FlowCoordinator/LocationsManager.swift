//
//  LocationsManager.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/12/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit
import MagicalRecord

protocol VisibleLocationsManagerDelegate
{
    func addCustomLocation(_ newCustomLocation: CustomLocation)
    func removeCustomLocation(_ customLocation: CustomLocation)
    func reloadAllCustomLocation()
}

class LocationsManager : NSObject
{
    static let Sydney = CLLocationCoordinate2DMake(-33.859823878555, 151.223348920464)
    
    var delegate: VisibleLocationsManagerDelegate?
    
    override init()
    {
        super.init()
        
        if UserDefaults.firstLaunch()
        {
            self.loadDefaultLocatios()
        }
    }
    
    func loadDefaultLocatios()
    {
        guard let filePath = Bundle.main.url(forResource: "DefaultLocations", withExtension: "json") else {
            return
        }
        
        let fileData : Data!
        do {
            fileData = try Data(contentsOf: filePath)
        }
        catch
        {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        let decoder = JSONDecoder()
        
        do {
            let defaultLocations = try decoder.decode(DefaultLocations.self, from: fileData)
            print("Parsed defaultLocations: \(defaultLocations)")
            
            for defaultLocation in defaultLocations.locations
            {
                guard let newLocation = CustomLocation.mr_createEntity(in: NSManagedObjectContext.mr_default()) else {
                    return
                }
                
                newLocation.name = "Default \(defaultLocation.name)"
                newLocation.lat = defaultLocation.lat
                newLocation.lon = defaultLocation.lng
            }
            
            NSManagedObjectContext.mr_default().mr_saveToPersistentStore { (success, error) in
                if success == false
                {
                    print("Error: \(error.debugDescription)")
                }
            }
            
        } catch {
            print("Error trying to convert data to JSON: \(error)")
            print(error)
            
        }
    }
    
    private lazy var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult> = {
        let context = NSManagedObjectContext.mr_default()
        
        let fetchRequest = CustomLocation.mr_requestAllSorted(by: "name", ascending: false, in: context)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    func createNewCustomLocation() -> CustomLocation?
    {
        let context = NSManagedObjectContext.mr_default()

        guard let newCustomLocation = CustomLocation.mr_createEntity(in: context) else {
            print("Error: New CustomLocation could not be created")
            return nil
        }

//        var newCustomLocation : CustomLocation?
//        MagicalRecord.save(blockAndWait: { (context) in
//            guard let customLocation = CustomLocation.mr_createEntity(in: context) else {
//                print("Error: New CustomLocation could not be created")
//                return
//            }
//
//            newCustomLocation = customLocation
//        })
        
        return newCustomLocation
    }
    
    // fetchedResultsController need to fetch at leas once to start receave changes in context
    func fetch()
    {
        do
        {
            try fetchedResultsController.performFetch()
        }
        catch
        {
            print("Error: \(error)")
        }
        
        print("Fetched count:\(String(describing: self.fetchedResultsController.fetchedObjects?.count))")
        
        self.delegate?.reloadAllCustomLocation()
    }
    
    func removeCustomeLocation(lat: Double, lon: Double)
    {
        guard let locationToDelete = customLocationFor(lat: lat, lon: lon) else {
            print("Error: don't find location to delete")
            return
        }
        let context = NSManagedObjectContext.mr_default()
        let deletionResult = locationToDelete.mr_deleteEntity(in: context)
        if deletionResult == false {
            print("Error: Could not delete selected location")
            return
        }
    }
    
    func customLocationFor(lat: Double, lon: Double) -> CustomLocation?
    {
        guard let fetchRequestResults = fetchedResultsController.fetchedObjects else {
            return nil
        }
        
        for fetchRequestResult in fetchRequestResults
        {
            guard let location = fetchRequestResult as? CustomLocation else {
                print("Error: Could not cast fetchRequestResult to CustomLocation")
                return nil
            }
            
            if location.lat == lat && location.lon == lon
            {
                return location
            }
        }
        
        return nil
    }
    
    func saveToPersistentStore() {
        let context = NSManagedObjectContext.mr_default()
        context.mr_saveToPersistentStoreAndWait()
    }
 }

extension LocationsManager : NSFetchedResultsControllerDelegate
{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type
        {
        case .insert:
            self.delegate?.addCustomLocation(anObject as! CustomLocation)
            break
        case .delete:
            self.delegate?.removeCustomLocation(anObject as! CustomLocation)
            break
        case .update:
            
            break
            
        default:
            // Do nothing
            break
        }
    }
}

// MARK: - VisibleLocations
extension LocationsManager
{
    func allVisibleLocations() -> [CustomLocation]?
    {
        guard let fetchedLocations = fetchedResultsController.fetchedObjects as? [CustomLocation] else {
            return nil
        }
        
        return fetchedLocations
    }
    
    func updateVisibleArea(neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D)
    {
        let minLat = min(neCoordinate.latitude, swCoordinate.latitude)
        let maxLat = max(neCoordinate.latitude, swCoordinate.latitude)
        
        let minLon = min(neCoordinate.longitude, swCoordinate.longitude)
        let maxLon = max(swCoordinate.longitude, neCoordinate.longitude)
        
        let predicate = NSPredicate(format: "\(minLat) <= lat AND lat <= \(maxLat) AND \(minLon) <= lon AND lon <= \(maxLon)")
        
        fetchedResultsController.fetchRequest.predicate = predicate
        fetch()
    }
}