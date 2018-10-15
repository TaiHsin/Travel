//
//  PofileViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/24.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher
import KeychainAccess

class ProfileViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    let keychain = Keychain(service: "com.TaiHsinLee.Travel")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showProfile()
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2.0
        profileImage.layer.masksToBounds = true
    }
    
    func showProfile() {
        
        guard let user = Auth.auth().currentUser else { return }
        
        let uid = user.uid
        let emial = user.email
        let name = user.displayName
        guard let photoURL = user.photoURL?.absoluteString else { return }
        let largePhotoURL = photoURL + "?type=large"
        
        print(uid)
        nameLabel.text = name
        emailLabel.text = emial
        profileImage.kf.setImage(with: URL(string: largePhotoURL))
    }
    
    @IBAction func logout(_ sender: Any) {
        
        let firbaseAuth = Auth.auth()
        
        let alertVC = AlertManager.shared.showAlert(with: ["Log out"], message: "Logging out?", cancel: true) {
            
            do {
                try firbaseAuth.signOut()
                
                self.keychain["userId"] = nil
                
                DispatchQueue.main.async {
                    AppDelegate.shared.window?.rootViewController
                        = UIStoryboard.loginStoryboard().instantiateInitialViewController()
                }
                
            } catch let signOutError as NSError {
                print("Error singing out: %@", signOutError)
            }
        }
        
        self.present(alertVC, animated: true, completion: nil)
    }
}
