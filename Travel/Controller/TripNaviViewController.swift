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
            NSAttributedString.Key.font: UIFont(name: "SFCompactText-Semibold", size: 17)!,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4235294118, green: 0.4588235294, blue: 0.5607843137, alpha: 1)
            ] as [NSAttributedString.Key: Any]
        
        self.navigationBar.titleTextAttributes = textAttributes
    }
}
