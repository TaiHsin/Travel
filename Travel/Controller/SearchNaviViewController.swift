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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBar.barTintColor = UIColor.darkGray
        UISearchBar.appearance().tintColor = UIColor.white
        navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.431372549, green: 0.4588235294, blue: 0.5529411765, alpha: 1)
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.431372549, green: 0.4588235294, blue: 0.5529411765, alpha: 1)
    }
}
