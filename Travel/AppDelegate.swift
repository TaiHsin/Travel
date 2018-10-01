//
//  AppDelegate.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/19.
//  Copyright © 2018年 TaiHsinLee. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GooglePlaces
import GoogleMaps
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        // FBSDK
        FBSDKApplicationDelegate.sharedInstance().application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // Firebase
        FirebaseApp.configure()
        
        // GoogleMap
        GMSPlacesClient.provideAPIKey("AIzaSyBlbzn0APNYiixRcg2wm-kg5QMLHwy8U7w")
        GMSServices.provideAPIKey("AIzaSyBlbzn0APNYiixRcg2wm-kg5QMLHwy8U7w")
        
        // IQKeyboard
        IQKeyboardManager.shared.enable = true
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
        ) -> Bool {
        
        // FBSDK
        let handled = FBSDKApplicationDelegate.sharedInstance().application(
            app,
            open: url,
            options: options
        )
        
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
 
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}
