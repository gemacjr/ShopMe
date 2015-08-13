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

class CDHelper : NSObject {
    
    // MARK: - SHARED INSTANCE
    class var shared : CDHelper {
        return _sharedCDHelper
    }
    
    // MARK: - PATHS
    lazy var storesDirectory: NSURL = {
        let fm = NSFileManager.defaultManager()
        let urls = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()
    lazy var localStoreURL: NSURL = {
        let url = self.storesDirectory.URLByAppendingPathComponent("LocalStore.sqlite")
        println("localStoreURL = \(url)")
        return url
    }()
    lazy var modelURL: NSURL = {
        let bundle = NSBundle.mainBundle()
        if let url = bundle.URLForResource("Model", withExtension: "momd"){
            return url
        }
        println("CRITICAL - MAnaged Object Model file not found")
        abort()
    }()
    
    
    // MARK: - CONTEXT
    lazy var context: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.coordinator
        return moc
    }()
    
    // MARK: - MODEL
    lazy var model: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL: self.modelURL)!
    }()
    
    // MARK: - COORDINATOR
    lazy var coordinator:NSPersistentStoreCoordinator = {
        return NSPersistentStoreCoordinator(managedObjectModel: self.model)
    }()
    
    // MARK: - STORE
    lazy var localStore: NSPersistentStore? = {
        
        let options = [NSSQLitePragmasOption:["journal_mode":"DELETE"],
            NSMigratePersistentStoresAutomaticallyOption:0,
            NSInferMappingModelAutomaticallyOption:1]
        
        var error: NSError?
        
        if let _localStore = self.coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.localStoreURL, options: options as [NSObject : AnyObject], error: &error) {
            return _localStore
        }
        if let _error = error {
            println("\(__FUNCTION__) ERROR: \(_error.localizedDescription)")
        }
        abort()
    }()
    
    // MARK: - SETUP
    required override init() {
        super.init()
        self.setupCoreData()
    }
    func setupCoreData() {
        let theLocalStore = self.localStore
    }
    
    // MARK: - SAVING
    class func save (moc:NSManagedObjectContext!) {
        
        if moc.hasChanges == false {
            println("SKIPPED save, context \(moc) has no changes")
            return
        }
        var error: NSError?
        if moc.save(&error) {
            
            println("SAVED context \(moc)")
            
            if moc.parentContext != nil {
                save(moc.parentContext)
            }
            return
        }
        if let _error = error {
            println("FAILED TO SAVE. \(_error.localizedDescription)")
        }
    }
    
    class func saveSharedContext() {
        CDHelper.save(CDHelper.shared.context)
    }
    
    
}