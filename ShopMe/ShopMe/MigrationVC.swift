//
//  MigrationVC.swift
//  ShopMe
//
//  Created by ED on 8/12/15.
//  Copyright (c) 2015 SwiftBeard. All rights reserved.
//

import UIKit

class MigrationVC: UIViewController {

    @IBOutlet var label: UILabel!
    @IBOutlet var progressView: UIProgressView!
    
    func progressChanged (note:AnyObject?) {
        if let _note = note as? NSNotification {
            if let progress = _note.object as? NSNumber {
                let progressFloat:Float = round(progress.floatValue * 100)
                let text = "Migration Progress: \(progressFloat)%"
                println(text)
                self.label.text = text
                self.progressView.progress = progress.floatValue
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "progressChanged", name: "migrationProgress", object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "migrationProgress", object: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
