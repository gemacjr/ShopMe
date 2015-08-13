//
//  PrepareTVC.swift
//  ShopMe
//
//  Created by ED on 8/12/15.
//  Copyright (c) 2015 SwiftBeard. All rights reserved.
//

import UIKit

class PrepareTVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate().demo()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
}
