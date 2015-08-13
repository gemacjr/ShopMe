//
//  CDMigration.swift
//  ShopMe
//
//  Created by ED on 8/12/15.
//  Copyright (c) 2015 SwiftBeard. All rights reserved.
//

import UIKit
import CoreData

private let _sharedCDMigration = CDMigration()
class CDMigration: NSObject {
    
    // MARK: - SHARED INSTANCE
    class var shared : CDMigration {
        return _sharedCDMigration
    }
    
    // MARK: - SUPPORTING FUNCTIONS
    func storeExistsAtPath(storeURL:NSURL) -> Bool {
        if let _storePath = storeURL.path {
            if NSFileManager.defaultManager().fileExistsAtPath(storeURL.path!) {
                return true
            }
        }
        return false
    }
    func store(storeURL:NSURL, isCompatibleWithModel model:NSManagedObjectModel) -> Bool {
        
        if self.storeExistsAtPath(storeURL) == false {
            return true // prevent migration of a store that does not exist
        }
        
        var error: NSError?
        if let metadata = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL: storeURL, error: &error) {
            
            if model.isConfiguration(nil, compatibleWithStoreMetadata: metadata) {
                println("The store is compatible with the current version of the model")
                return true
            }
        }
        println("The store is NOT compatible with the current version of the model")
        return false
    }
    func replaceStore(oldStore:NSURL, newStore:NSURL) -> Bool {
        
        let manager = NSFileManager.defaultManager()
        var error: NSError?
        
        if manager.removeItemAtURL(oldStore, error: &error) {
            error = nil
            if manager.moveItemAtURL(newStore, toURL: oldStore, error: &error) {
                return true // success
            }
        }
        
        if let _error = error {
            println("ERROR: \(_error.localizedDescription)")
        }
        return false // fail
    }
    
    // MARK: - PROGRESS REPORTING
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if object is NSMigrationManager, let manager = object as? NSMigrationManager {
                
                NSNotificationCenter.defaultCenter().postNotificationName(keyPath, object: NSNumber(float: manager.migrationProgress))
                
            } else {println("observeValueForKeyPath did not receive a NSMigrationManager class")}
        })
    }
    
    // MARK: - MIGRATION
    func migrateStore(store:NSURL, sourceModel:NSManagedObjectModel, destinationModel:NSManagedObjectModel) {
        
        if let tempdir = store.URLByDeletingLastPathComponent {
            let tempStore = tempdir.URLByAppendingPathComponent("Temp.sqlite")
            let mappingModel = NSMappingModel(fromBundles: nil, forSourceModel: sourceModel, destinationModel: destinationModel)
            let migrationManager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)
            migrationManager.addObserver(self, forKeyPath: "migrationProgress", options: NSKeyValueObservingOptions.New, context: nil)
            var error: NSError?
            if migrationManager.migrateStoreFromURL(store, type: NSSQLiteStoreType, options: nil, withMappingModel: mappingModel, toDestinationURL: tempStore, destinationType: NSSQLiteStoreType, destinationOptions: nil, error: &error) {
                
                if self.replaceStore(store, newStore: tempStore) {
                    println("SUCCESSFULLY MIGRATED \(store) to the Current Model")
                }
            }
            if let _error = error {
                println("FAILED MIGRATION: \(_error.localizedDescription)")
            }
            migrationManager.removeObserver(self, forKeyPath: "migrationProgress")
        }
    }
    func migrateStoreWithProgressUI(store:NSURL, sourceModel:NSManagedObjectModel, destinationModel:NSManagedObjectModel) {
        
        // Show migration progress view preventing the user from using the app
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let application = UIApplication.sharedApplication
        
        if let initialVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController {
            
            if let migrationVC = storyboard.instantiateViewControllerWithIdentifier("migration") as? MigrationVC {
                
                initialVC.presentViewController(migrationVC, animated: false, completion: {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        println("BACKGROUND Migration started...")
                        self.migrateStore(store, sourceModel: sourceModel, destinationModel: destinationModel)
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            // trigger the stack setup again, this time with the upgraded store
                            let theLocalStore = CDHelper.shared.localStore
                            dispatch_after(2, dispatch_get_main_queue(), {
                                migrationVC.dismissViewControllerAnimated(false, completion: nil)
                            })
                        })
                    })
                })
            } else {println("FAILED to find a view controller with a story board id of 'migration'")}
        } else {println("FAILED to find the root view controller, which is supposed to be a navigation controller")}
    }
    func migrateStoreIfNecessary (storeURL:NSURL, destinationModel:NSManagedObjectModel) {
        
        if storeExistsAtPath(storeURL) == false {
            return
        }
        
        if store(storeURL, isCompatibleWithModel: destinationModel) {
            return
        }
        
        var error: NSError?
        if let metadata = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL: storeURL, error: &error) {
            
            if let sourceModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()], forStoreMetadata: metadata) {
                
                self.migrateStoreWithProgressUI(storeURL, sourceModel: sourceModel, destinationModel: destinationModel)
            }
        }
    }
    
}   
