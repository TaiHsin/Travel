//
//  UIViewController+Extension.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/11/8.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func tra_addContentController(
        _ child: UIViewController,
        to containerView: UIView
        ) {
        
        addChild(child)
        
        containerView.addSubview(child.view)
        
        child.view.frame = containerView.frame
        
        child.didMove(toParent: self)
    }
    
    func tra_removeContentController(
        _ child: UIViewController,
        from containerView: UIView
        ) {
        
        child.willMove(toParent: nil)
        
        child.view.removeFromSuperview()
        
        child.removeFromParent()
    }
}
