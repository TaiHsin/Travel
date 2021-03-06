//
//  NavigationViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/20.
//  Copyright © 2018年 TaiHsinLee. All rights reserved.
//

import UIKit

class SearchNaviViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBar.barTintColor = UIColor.darkGray
        
        UISearchBar.appearance().tintColor = UIColor.white
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor.battleshipGrey
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor.battleshipGrey
    }
}
