//
//  TabBarViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/25.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

private enum Tab {
    
    case myTrip
    
    case preserved
    
    case package
    
    case profile
    
    func controller() -> UIViewController {
        
        switch self {
            
        case .myTrip:
            
            return UIStoryboard.myTripStoryboard().instantiateInitialViewController()!
            
        case .preserved:
            
            return UIStoryboard.preservedStoryboard().instantiateInitialViewController()!
            
        case .package:
            
            return UIStoryboard.packageStoryboard().instantiateInitialViewController()!
            
        case .profile:
            
            return UIStoryboard.profileStoryboard().instantiateInitialViewController()!
            
        }
    }
    
    func image() -> UIImage {
        
        switch self {
            
        case .myTrip: return #imageLiteral(resourceName: "main_black")
            
        case .preserved: return #imageLiteral(resourceName: "wishlist_black")
            
        case .package: return #imageLiteral(resourceName: "baggage_black")
            
        case .profile: return #imageLiteral(resourceName: "profile_black")
        }
    }
    
    func selectedImage() -> UIImage {
        
        switch self {
            
        case .myTrip: return #imageLiteral(resourceName: "main_black").withRenderingMode(.alwaysTemplate)
            
        case .preserved: return #imageLiteral(resourceName: "wishlist_black").withRenderingMode(.alwaysTemplate)
        
        case .package: return #imageLiteral(resourceName: "baggage_black").withRenderingMode(.alwaysTemplate)
        
        case .profile: return #imageLiteral(resourceName: "profile_black").withRenderingMode(.alwaysTemplate)
            
        }
    }
}

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTab()
    }
    
    private func setupTab() {
        
        tabBar.tintColor = #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1)
        
        var controllers: [UIViewController] = []
        
        let tabs: [Tab] = [.myTrip, .preserved, .package, .profile]
        
        for tab in tabs {
            
            let controller = tab.controller()
            
            let item = UITabBarItem(
                title: nil,
                image: tab.image(),
                selectedImage: tab.selectedImage()
            )
            
            item.imageInsets = UIEdgeInsets(
                top: 6,
                left: 0,
                bottom: -6,
                right: 0
            )
            
            controller.tabBarItem = item
            
            controllers.append(controller)
        }
        
        setViewControllers(controllers, animated: false)
    }
}
