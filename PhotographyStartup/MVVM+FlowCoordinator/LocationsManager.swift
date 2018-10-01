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
    
    // In order to get notified of changes in Location model, all CRUD operations should use same NSManagedObjectContext
    private let context = NSManagedObjectContext.mr_default()
    
    override init()
    {
        super.init()
        
        if UserDefaults.firstLaunch()
        {
            loadDefaultLocatios()
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
                guard let newLocation = Location.mr_createEntity(in: context) else {
                    return
                }
                
                newLocation.name = "Default \(defaultLocation.name)"
                newLocation.lat = defaultLocation.lat
                newLocation.lon = defaultLocation.lng
            }
            
            context.mr_saveToPersistentStore { (contextDidSave, error) in
                if !contextDidSave
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
        let fetchRequest = Location.mr_requestAllSorted(by: "name", ascending: false, in: context)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    func createLocation() -> Location?
    {
        guard let newLocation = Location.mr_createEntity(in: context) else {
            print("Error: New CustomLocation could not be created")
            return nil
        }

        // Recomended but less convenient
        //   var newCustomLocation : CustomLocation?
        //   MagicalRecord.save(blockAndWait: { (context) in
        //       guard let customLocation = CustomLocation.mr_createEntity(in: context) else {
        //           print("Error: New CustomLocation could not be created")
        //           return
        //       }
        //
        //       newCustomLocation = customLocation
        //   })
        
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
        
        print("Fetched count:\(String(describing: visibleLocationsFetchedResultsController.fetchedObjects?.count))")
        
        delegate?.locationsReloaded()
    }
    
    func removeLocation(_ location: Location)
    {
        let deletionResult = location.mr_deleteEntity()
        if !deletionResult {
            print("Error: Could not delete selected location")
            return
        }
    }
    
    func locationFor(locationId: String) -> Location?
    {
        guard let objectIDURL = URL(string: locationId),
              let coordinator = context.persistentStoreCoordinator,
              let managedObjectID = coordinator.managedObjectID(forURIRepresentation: objectIDURL) else
        {
            print("Error: could not create managedObjectID from locationId: \(locationId)")
            return nil
        }
        
        guard let location = context.object(with: managedObjectID) as? Location else
        {
            print("Error: could not find location for \(managedObjectID)")
            return nil
        }
        
        return location
    }
    
    func saveToPersistentStore()
    {
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
            delegate?.locationAdded(location)
            
        case .delete:
            delegate?.locationRemoved(location)
            
        case .update:
            delegate?.locationUpdated(location, indexPath: newIndexPath)
            
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
        
        let minLatNSNumber = NSNumber(value:minLat)
        let maxLatNSNumber = NSNumber(value:maxLat)
        
        let minLonNSNumber = NSNumber(value:minLon)
        let maxLonNSNumber = NSNumber(value:maxLon)
        
        let predicate = NSPredicate(format: "\(minLatNSNumber) <= lat AND lat <= \(maxLatNSNumber) AND \(minLonNSNumber) <= lon AND lon <= \(maxLonNSNumber)")
        print("predicateN: \(predicate)")
        
        visibleLocationsFetchedResultsController.fetchRequest.predicate = predicate
        fetch()
    }
}
