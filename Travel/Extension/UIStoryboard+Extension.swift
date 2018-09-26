//
//  UIStoryboard+Extension.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/25.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static func mainStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    static func tripDetailStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "TripDetail", bundle: nil)
    }
}
