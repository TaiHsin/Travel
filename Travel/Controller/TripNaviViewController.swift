//
//  TripNaviViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/25.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class TripNaviViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        
        let textAttributes = [
            NSAttributedString.Key.font: UIFont(name: "SFCompactText-Semibold", size: 18.5)!,
            NSAttributedString.Key.foregroundColor: UIColor.battleshipGrey
            ] as [NSAttributedString.Key: Any]
        
        self.navigationBar.titleTextAttributes = textAttributes
    }
}
