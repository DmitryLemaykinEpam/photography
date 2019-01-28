//
//  CoreDataStack.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 1/24/19.
//  Copyright © 2019 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack
{
    private let modelName: String
    
    lazy var mainContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    init(modelName: String)
    {
        self.modelName = modelName
    }
}

extension CoreDataStack
{
    func saveContext ()
    {
        guard mainContext.hasChanges else {
            return
        }
        
        do {
            try mainContext.save()
        } catch let nserror as NSError {
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
