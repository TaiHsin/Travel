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
    
    typealias ActionHandler = (UIAlertAction) -> Void
    
    /// Not used yet, wait for refactor and gether alert func. here together
    
    func showAlert(
        with title: [String],
        message: String,
        cancel: Bool,
        completion: @escaping () -> Void
        ) -> UIAlertController {
        
        let alertController = UIAlertController(title: title.first, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
            
            completion()
        })
        
        alertController.addAction(action)
        
        guard cancel == true else {
            
            return alertController
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
    
        return alertController
    }
    
    func showActionSheet(
        defaultOptions: [String],
        defaultCompletion: @escaping ActionHandler,
        destructiveOptions: [String],
        destructiveCompletion: @escaping ActionHandler
        ) -> UIAlertController {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        for item in defaultOptions {
            
            let action = UIAlertAction(title: item, style: .default, handler: { action in
                
                defaultCompletion(action)
            })
            
            alertController.addAction(action)
        }
        
        for item in destructiveOptions {
            
            let action = UIAlertAction(title: item, style: .destructive, handler: { action in
                destructiveCompletion(action)
            })
            
            alertController.addAction(action)
        }

        return alertController
    }
}
