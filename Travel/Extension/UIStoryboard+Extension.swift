//
//  UIStoryboard+Extension.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/25.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static func loginStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Login", bundle: nil)
    }
    
    static func mainStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    static func myTripStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "MyTrip", bundle: nil)
    }
    
    static func preservedStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Preserved", bundle: nil)
    }
    
    static func packageStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Checklist", bundle: nil)
    }
    
    static func profileStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Profile", bundle: nil)
    }
    
    static func searchStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Search", bundle: nil)
    }
}
