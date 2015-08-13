//
//  AppDelegate.swift
//  ShopMe
//
//  Created by ED on 8/11/15.
//  Copyright (c) 2015 SwiftBeard. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        CDHelper.saveSharedContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func demo() {
        
        let context = CDHelper.shared.context
        let kg =      NSEntityDescription.insertNewObjectForEntityForName("Unit", inManagedObjectContext: context) as! Unit
        let oranges = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: context) as! Item
        let bananas = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: context) as! Item
        
        kg.name = "Kg"
        oranges.name = "Oranges"
        bananas.name = "Bananas"
        
        oranges.quantity = NSNumber(float: 1)
        bananas.quantity = NSNumber(float: 4)
        
        oranges.listed = NSNumber(bool: true)
        bananas.listed = NSNumber(bool: true)
        
        oranges.unit = kg
        bananas.unit = kg
        
        println("Inserted \(oranges.quantity)\(oranges.unit.name) of \(oranges.name)")
        println("Inserted \(bananas.quantity)\(bananas.unit.name) of \(bananas.name)")
        
        CDHelper.saveSharedContext()
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

