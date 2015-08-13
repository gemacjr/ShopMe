//
//  CDHelper.swift
//  ShopMe
//
//  Created by ED on 8/12/15.
//  Copyright (c) 2015 SwiftBeard. All rights reserved.
//

import Foundation
import CoreData

private let _sharedCDHelper = CDHelper()
class CDHelper : NSObject  {
    
    // MARK: - SHARED INSTANCE
    class var shared : CDHelper {
        return _sharedCDHelper
    }
    
    // MARK: - PATHS
    lazy var storesDirectory: NSURL? = {
        let fm = NSFileManager.defaultManager()
        let urls = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as? NSURL
        }()
    lazy var localStoreURL: NSURL? = {
        let url = self.storesDirectory?.URLByAppendingPathComponent("LocalStore.sqlite")
        println("localStoreURL = \(url!)")
        return url
        }()
    lazy var modelURL: NSURL = {
        let bundle = NSBundle.mainBundle()
        if let url = bundle.URLForResource("Model", withExtension: "momd") {
            return url
        }
        println("CRITICAL - Managed Object Model file not found")
        abort()
        }()
    
    // MARK: - CONTEXT
    lazy var context: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType:.MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.coordinator
        return moc
        }()
    
    // MARK: - MODEL
    lazy var model: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL:self.modelURL)!
        }()
    
    // MARK: - COORDINATOR
    lazy var coordinator:NSPersistentStoreCoordinator = {
        return NSPersistentStoreCoordinator(managedObjectModel:self.model)
        }()
    
    // MARK: - STORE
    lazy var localStore: NSPersistentStore? = {
        
        if let _localStoreURL = self.localStoreURL {
            
            let useMigrationManager = false
            if useMigrationManager == true &&
                CDMigration.shared.storeExistsAtPath(_localStoreURL) &&
                CDMigration.shared.store(_localStoreURL, isCompatibleWithModel: self.model) == false {
                    return nil // Don't return a store if it's not compatible with the model
            }
            
            let options:[NSObject:AnyObject] = [NSSQLitePragmasOption:["journal_mode":"DELETE"],
                NSMigratePersistentStoresAutomaticallyOption:1,
                NSInferMappingModelAutomaticallyOption:1]
            var error: NSError?
            if let _localStore = self.coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: _localStoreURL, options: options, error: &error) {
                return _localStore
            }
            if let _error = error {
                println("\(__FUNCTION__) ERROR: \(_error.localizedDescription)")
            }
        }
        return nil
        }()
    
    // MARK: - SETUP
    required override init() {
        super.init()
        self.setupCoreData()
    }
    func setupCoreData() {
        
        // Model Migration
        /*if let _localStoreURL = self.localStoreURL {
        CDMigration.shared.migrateStoreIfNecessary(_localStoreURL, destinationModel: self.model)
        } */
        
        // Load Local Store
        let theLocalStore = self.localStore
    }
    
    
    // MARK: - SAVING
    class func save (moc:NSManagedObjectContext!) {
        
        moc.performBlockAndWait {
            if moc.hasChanges == false {
                println("SKIPPED SAVE, context \(moc.description) has no changes")
                return
            }
            var error:NSError?
            if moc.save(&error) {
                println("SAVED context \(moc.description)")
                if moc.parentContext != nil {
                    CDHelper.save(moc.parentContext)
                }
            } else if let _error = error {
                println("FAILED TO SAVE. \(_error.localizedDescription)")
            } else {
                println("FAILED TO SAVE. No error was returned.")
            }
        }
    }
    class func saveSharedContext () {
        CDHelper.save(CDHelper.shared.context)
    }
    
    
    
}