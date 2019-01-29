//
//  LocationsManager.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/12/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//
//  CRUD Opereations For Places

import UIKit
import MapKit
import CoreData

import RxSwift

class PlacesManager: NSObject
{
    // In order to get notified of changes in Place model, all CRUD operations should use same NSManagedObjectContext
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext)
    {
        self.context = context
        
        super.init()
        
        if UserDefaults.firstLaunch()
        {
            loadDefaultLocatios()
        }
    }
    
    func createPlace() -> Place?
    {
        var newPlace: Place?
        self.context.performAndWait
        {
            newPlace = NSEntityDescription.insertNewObject(forEntityName: "Place", into: self.context) as? Place
        }
        return newPlace
    }
    
    func removePlace(_ pleceToRemove: Place)
    {
        self.context.performAndWait
        {
            self.context.delete(pleceToRemove)
        }
        saveContext(context: self.context)
    }
    
    func placeFor(placeId: String?) -> Place?
    {
        guard let placeId = placeId else {
            return nil
        }
        
        guard let objectIDURL = URL(string: placeId),
              let coordinator = self.context.persistentStoreCoordinator,
              let managedObjectID = coordinator.managedObjectID(forURIRepresentation: objectIDURL) else
        {
            print("Error: could not create managedObjectID from locationId: \(placeId)")
            return nil
        }
        
        guard let place = self.context.object(with: managedObjectID) as? Place else
        {
            print("Error: could not find location for \(managedObjectID)")
            return nil
        }
        
        return place
    }
    
    func saveContext()
    {
        saveContext(context: self.context)
    }
    
    func saveContext(context: NSManagedObjectContext)
    {
        context.perform {
            guard context.hasChanges else {
                return
            }
            
            do {
                try context.save()
                
//                guard let parentContext = context.parent else {
//                    return
//                }
//                self.saveContext(context: parentContext)
            } catch {
                print(error)
            }
        }
    }
}

extension PlacesManager
{
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
                let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Place", into: self.context) as! Place
                newPlace.name = "Default \(defaultLocation.name)"
                newPlace.lat = defaultLocation.lat
                newPlace.lon = defaultLocation.lng
            }
            
            saveContext(context: self.context)
            
        } catch {
            print("Error trying to convert data to JSON: \(error)")
        }
    }
}
