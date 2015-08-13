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
}
