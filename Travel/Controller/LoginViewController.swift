//
//  LoginViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/19.
//  Copyright © 2018年 TaiHsinLee. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import KeychainAccess

class LoginViewController: UIViewController {

    @IBOutlet weak var facebookButton: UIButton!
    
    @IBOutlet weak var anonymousButton: UIButton!
    
    private let manager = FacebookManager()
    
    let keychain = Keychain(service: "com.TaiHsinLee.Travel")
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        facebookButton.layer.cornerRadius = 8.0
        anonymousButton.layer.cornerRadius = 8.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        anonymousButton.layer.borderWidth = 1.0
    }

    // MARK: - Set status bar color at specific View Controller
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func loninAnonymously(_ sender: UIButton) {
        
        Auth.auth().signInAnonymously { (authResult, error) in
            
            if let error = error {
                
                print("Login Failed: \(error.localizedDescription)")
                return
            }
            
            let user = authResult?.user
//            let isAnonymous = user?.isAnonymous
//            let uid = user?.uid
            
            print(user.debugDescription)
            
            DispatchQueue.main.async {
                
                AppDelegate.shared.window?.rootViewController
                    = UIStoryboard
                        .mainStoryboard()
                        .instantiateInitialViewController()
            }
        }
    }
    
    @IBAction func loginFacebook(_ sender: Any) {
        
        manager.facebookLogin(
            fromController: self,
            success: { [weak self] token in
                
                let credential = FacebookAuthProvider.credential(withAccessToken: token)

                Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, error) in
                    if let error = error {
                        
                        print("Login Failed: \(error.localizedDescription)")
                        return
                    }

                    let user = authResult?.user
                    guard let uid = user?.uid else { return }
                    
                    /// store uid or getIDtoken?
                    
                    self?.keychain["userId"] = uid
    
                    DispatchQueue.main.async {
                    
                        AppDelegate.shared.window?.rootViewController
                            = UIStoryboard
                                .mainStoryboard()
                                .instantiateInitialViewController()
                    }
                })
            },
            failure: { (_) in
                // TODO
            })
    }
}
