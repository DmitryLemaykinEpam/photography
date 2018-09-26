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
import Bond

// Bond approach with MutableObservableArray is not suitable for this dalaguete in this case,
// because array going to be replaced
protocol LocationsManagerDelegate
{
    func locationAdded(_ location: Location)
    func locationUpdated(_ updatedLocation: Location, indexPath: IndexPath?)
    func locationRemoved(_ location: Location)
    func locationsReloaded()
}

class LocationsManager : NSObject
{
    var delegate: LocationsManagerDelegate?
    
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
                guard let newLocation = Location.mr_createEntity(in: NSManagedObjectContext.mr_default()) else {
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
    
    private lazy var visibleLocationsFetchedResultsController : NSFetchedResultsController<NSFetchRequestResult> =
    {
        let context = NSManagedObjectContext.mr_default()
        
        let fetchRequest = Location.mr_requestAllSorted(by: "name", ascending: false, in: context)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    func createLocation() -> Location?
    {
        let context = visibleLocationsFetchedResultsController.managedObjectContext
        
        guard let newLocation = Location.mr_createEntity(in: context) else {
            print("Error: New CustomLocation could not be created")
            return nil
        }

        // Recomended but less convenient
//        var newCustomLocation : CustomLocation?
//        MagicalRecord.save(blockAndWait: { (context) in
//            guard let customLocation = CustomLocation.mr_createEntity(in: context) else {
//                print("Error: New CustomLocation could not be created")
//                return
//            }
//
//            newCustomLocation = customLocation
//        })
        
        return newLocation
    }
    
    // fetchedResultsController need to performFetch at least once to start to receive changes in context
    func fetch()
    {
        do
        {
            try visibleLocationsFetchedResultsController.performFetch()
        }
        catch
        {
            print("Error: \(error)")
        }
        
        print("Fetched count:\(String(describing: self.visibleLocationsFetchedResultsController.fetchedObjects?.count))")
        
        self.delegate?.locationsReloaded()
    }
    
    func removeLocation(_ location: Location)
    {
        let context = NSManagedObjectContext.mr_default()
        let deletionResult = location.mr_deleteEntity(in: context)
        if deletionResult == false {
            print("Error: Could not delete selected location")
            return
        }
    }
    
    func locationFor(name: String?, coordinate: CLLocationCoordinate2D) -> Location?
    {
        guard let fetchRequestResults = visibleLocationsFetchedResultsController.fetchedObjects, fetchRequestResults.count > 0 else {
            return nil
        }
        
        for fetchRequestResult in fetchRequestResults
        {
            guard let location = fetchRequestResult as? Location else {
                print("Error: Could not cast fetchRequestResult to CustomLocation")
                return nil
            }
            
            if  location.name == name &&
                location.lat == coordinate.latitude &&
                location.lon == coordinate.longitude
            {
                return location
            }
        }
        
        return nil
    }
    
    func saveToPersistentStore()
    {
        let context = NSManagedObjectContext.mr_default()
        context.mr_saveToPersistentStoreAndWait()
    }
 }

extension LocationsManager: NSFetchedResultsControllerDelegate
{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        guard let location = anObject as? Location else {
            print("Error: anObject is not a Loaction")
            return
        }
        
        switch type
        {
        case .insert:
            self.delegate?.locationAdded(location)
            
        case .delete:
            self.delegate?.locationRemoved(location)
            
        case .update:
            self.delegate?.locationUpdated(location, indexPath: indexPath)
            
        case .move:
            // Do nothing
            break
        }
    }
}

// MARK: - VisibleLocations
extension LocationsManager
{
    func visibleLocations() -> [Location]?
    {
        guard let fetchedLocations = visibleLocationsFetchedResultsController.fetchedObjects as? [Location] else {
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
        
        let minLatFormatted = String(format: "%.16f", minLat)
        let maxLatFormatted = String(format: "%.16f", maxLat)
        
        let minLonFormatted = String(format: "%.16f", minLon)
        let maxLonFormatted = String(format: "%.16f", maxLon)
        
        let predicate = NSPredicate(format: "\(minLatFormatted) <= lat AND lat <= \(maxLatFormatted) AND \(minLonFormatted) <= lon AND lon <= \(maxLonFormatted)")
        
        visibleLocationsFetchedResultsController.fetchRequest.predicate = predicate
        fetch()
    }
}
