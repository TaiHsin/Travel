//
//  AlertManager.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/29.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    typealias ActionHandler = (UIAlertAction) -> Void
    
    typealias AlertHandler = () -> Void
    
    static func showAlert(
        title: String?,
        message: String,
        cancel: Bool,
        completion: AlertHandler? = nil
        ) -> UIAlertController {
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in
            
                completion?()
        })
        
        alertController.addAction(action)
        
        guard cancel == true else {
            
            return alertController
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    static func showActionSheet(
        defaultOptions: [String],
        defaultCompletion: @escaping ActionHandler,
        destructiveOptions: [String]? = nil,
        destructiveCompletion: ActionHandler? = nil
        ) -> UIAlertController {
        
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        alertController.addAction(cancelAction)
        
        for item in defaultOptions {
            
            let action = UIAlertAction(
                title: item,
                style: .default,
                handler: { action in
                
                    defaultCompletion(action)
            })
            
            alertController.addAction(action)
        }
        
        guard let destructiveOptions = destructiveOptions else {
            
            return alertController
        }
        
        for item in destructiveOptions {
            
            let action = UIAlertAction(
                title: item,
                style: .destructive,
                handler: { action in
                
                    destructiveCompletion?(action)
            })
            
            alertController.addAction(action)
        }
        
        return alertController
    }
}
