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

class LoginViewController: UIViewController {

    @IBOutlet weak var fbLoginButton: UIButton!
    
    private let manager = FacebookManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func loginFacebook(_ sender: Any) {
        
        manager.facebookLogin(
            fromController: self,
            success: { [weak self] token in
                
//                guard let accessToken = FBSDKAccessToken.current() else {
//                    
//                    print("Failed to get access token")
//                    return
//                }
                
                let credential = FacebookAuthProvider.credential(withAccessToken: token)
                
                Auth.auth().signInAndRetrieveData(with: credential, completion: { (auhtResult, error) in
                    if let error = error {
                        
                        print("Login Failed: \(error.localizedDescription)")
                        return
                    }
                    print("--------------------------------------")
                    print(Auth.auth().currentUser?.displayName)
                    print(Auth.auth().currentUser?.email)
                    print(Auth.auth().currentUser?.photoURL)
                })
            },
            failure: { (_) in
                // TODO
            })
    }
    
}
