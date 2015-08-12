//
//  Item.swift
//  ShopMe
//
//  Created by ED on 8/12/15.
//  Copyright (c) 2015 SwiftBeard. All rights reserved.
//

import Foundation
import CoreData

class Item: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var quantity: NSNumber
    @NSManaged var photoData: NSData
    @NSManaged var collected: NSNumber
    @NSManaged var listed: NSNumber

}
