//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Jonathan Gerardo on 6/27/21.
//

import Foundation
import CoreData

class DataController {
    
    let persistantContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    init(modelName:String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }
    
    var backgroundContext:NSManagedObjectContext!
    
    
    func configureViewContext() {
        backgroundContext = persistantContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
    }
    
    
    func load(completion: (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.configureViewContext()
            self.autoSaveViewContext()
            completion?()
        }
        
        
    }
    
   
}



extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        guard interval > 0 else {
            print("error saving")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.async {
            self.autoSaveViewContext(interval: interval)
        }
        
    }
}
