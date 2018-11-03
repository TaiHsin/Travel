//
//  ViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/14.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

/// for San Francisco font extension???

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        for family: String in UIFont.familyNames {
            print("\(family)")
            
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
    }
}
