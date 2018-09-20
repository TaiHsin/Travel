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
                
                let credential = FacebookAuthProvider.credential(withAccessToken: token)
    
                Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, error) in
                    if let error = error {
                        
                        print("Login Failed: \(error.localizedDescription)")
                        return
                    }
                    print("--------------------------------------")
                    print(authResult?.user.displayName)
                    print(authResult?.user.email)
                    print(authResult?.user.photoURL)
                })
            },
            failure: { (_) in
                // TODO
            })
    }
}
