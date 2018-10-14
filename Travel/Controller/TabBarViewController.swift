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
            
        case .myTrip: return #imageLiteral(resourceName: "tab_trips_normal")
            
        case .preserved: return #imageLiteral(resourceName: "tab_collections_normal")
            
        case .package: return #imageLiteral(resourceName: "tab_packlist_normal")
            
        case .profile: return #imageLiteral(resourceName: "tab_profile_normal")
        }
    }
    
    func selectedImage() -> UIImage {
        
        switch self {
            
        case .myTrip: return #imageLiteral(resourceName: "tab_trips").withRenderingMode(.alwaysTemplate)
            
        case .preserved: return #imageLiteral(resourceName: "tab_collections").withRenderingMode(.alwaysTemplate)
        
        case .package: return #imageLiteral(resourceName: "tab_packlist").withRenderingMode(.alwaysTemplate)
        
        case .profile: return #imageLiteral(resourceName: "tab_profile").withRenderingMode(.alwaysTemplate)
            
        }
    }
}

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTab()
    }
    
    private func setupTab() {
        
        tabBar.tintColor = #colorLiteral(red: 0.4235294118, green: 0.4588235294, blue: 0.5607843137, alpha: 1)
        
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
