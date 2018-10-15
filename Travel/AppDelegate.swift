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
import KeychainAccess
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // swiftlint:disable force_cast
    static let shared = UIApplication.shared.delegate as! AppDelegate
    // swiftlint:enable force_cast
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        
        // Crashlytics
        Fabric.with([Crashlytics.self])
        
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
        
//        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.4235294118, green: 0.4588235294, blue: 0.5607843137, alpha: 1)
        
        let keychain = Keychain(service: "com.TaiHsinLee.Travel")
    
        guard keychain["userId"] == nil else {
            
            switchToMainStoryBoard()
            
            return true
        }
        
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
    
    func switchToLoginStoryBoard() {
        
        guard Thread.current.isMainThread else {
            
            DispatchQueue.main.async { [weak self] in
                
                self?.switchToLoginStoryBoard()
            }
            
            return
        }
        
        window?.rootViewController = UIStoryboard.loginStoryboard().instantiateInitialViewController()
    }
    
    func switchToMainStoryBoard() {
        
        guard Thread.current.isMainThread else {
            
            DispatchQueue.main.async { [weak self] in
                
                self?.switchToMainStoryBoard()
            }
            
            return
        }
        
        window?.rootViewController = UIStoryboard.mainStoryboard().instantiateInitialViewController()
    }
    
}
