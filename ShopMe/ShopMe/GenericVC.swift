//
//  GenericVC.swift
//  ShopMe
//
//  Created by ED on 8/11/15.
//  Copyright (c) 2015 SwiftBeard. All rights reserved.
//

import UIKit

class GenericVC: UIViewController {
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func hideKeyboardWhenBackgroundIsTapped() {
        let tgr = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
        self.view.addGestureRecognizer(tgr)
    }
}
