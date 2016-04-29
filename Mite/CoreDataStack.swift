//
//  CoreDataStack.swift
//  Mite
//
//  Created by jpk on 4/27/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import CoreData

enum CoreDataError: ErrorType {
    case Failure(error: String)
}

class CoreDataStack {
    
    static let sharedInstance = CoreDataStack()
    
    let modelName = "Image"
    
    lazy var context: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = self.psc
        return managedObjectContext
    }()
    
    private lazy var psc: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.modelName)
        
        do {
            let options =
                [NSMigratePersistentStoresAutomaticallyOption : true]
            
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch  {
            print("Error adding persistent store.")
        }
        
        return coordinator
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    func fetch(entity: String, predicate: NSPredicate? = nil, fetchLimit: Int = 0, moc: NSManagedObjectContext) throws -> [AnyObject]? {
        let fetch = NSFetchRequest(entityName: entity)
        fetch.predicate = predicate
        fetch.fetchLimit = fetchLimit
        do {
            let result = try moc.executeFetchRequest(fetch)
            return result
        } catch let error {
            print("Failed to fetch \(entity) with predicate \(predicate): \(error)")
            throw error
        }
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
    
    func handleError(e:ErrorType) {
        CoreDataError.Failure(error: "CoreDataError: \(e)")
    }
}