//
//  AlertManager.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/29.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class AlertManager {
    
    static let shared = AlertManager()
    
    /// Not used yet, wait for refactor and gether alert func. here together
    
    func showAlert(with title: String?, message: String, completion: @escaping () -> Void) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        }
        
        alertController.addAction(action)
        
        return alertController
    }
}
