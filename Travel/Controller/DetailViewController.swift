//
//  DetailViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/29.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import FirebaseDatabase
import Firebase
import KeychainAccess
import SwiftMessages

class DetailViewController: UIViewController {
    
    @IBOutlet weak var placeName: UILabel!
    
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var placeImage: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var myTripButton: UIButton!
    
    @IBOutlet weak var placeInfoCard: UIView!
    
    @IBOutlet var detailInfoView: UIView!
    
    @IBOutlet weak var myTripsButtonWidthConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var favoriteButtonWidthConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var intervalConstraints: NSLayoutConstraint!
    
    let keychain = Keychain(service: "com.TaiHsinLee.Travel")
    
    var ref: DatabaseReference!
    
    let photoManager = PhotoManager()
    
    let alertManager = AlertManager()
    
    let dateFormatter = DateFormatter()
    
    var total = 0
    
    var location: Location?
    
    var isFavorite = false
    
    var isMyTrip = false
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    var tabIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.view.frame = CGRect(x: 0, y: 0, width: fullScreenSize.width, height: fullScreenSize.height)
        
        ref = Database.database().reference()
        showAnimate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        
        placeInfoCard.layer.cornerRadius = 8
        placeInfoCard.layer.masksToBounds = true
        placeImage.clipsToBounds = true
        
        if isMyTrip || tabIndex == 2 {
            
            let width = myTripsButtonWidthConstraints.constant
            myTripsButtonWidthConstraints.constant = 0.0
            favoriteButtonWidthConstraints.constant += width
            intervalConstraints.constant = 0.0
        } else if isFavorite || tabIndex == 1 {
            
            let width = favoriteButtonWidthConstraints.constant
            favoriteButtonWidthConstraints.constant = 0.0
            myTripsButtonWidthConstraints.constant += width
            intervalConstraints.constant = 0.0
        }
        
        #warning ("below shouldn't in viewWillAppear?")
        
        guard let location = location else { return }
        let placeId = location.photo
        
        placeName.text = location.name
        positionLabel.text = location.address
        
        photoManager.loadFirstPhotoForPlace(placeID: placeId, success: { (photo) in
            
            self.placeImage.image = photo
        }, failure: { (error) in
            // TODO:
        })
    }
    
    func setupMessageView() {
        
        // Instantiate a message view from the provided card view layout. SwiftMessages searches for nib
        // files in the main bundle first, so you can easily copy them into your project and make changes.
        let view = MessageView.viewFromNib(layout: .messageView)
        
        // Theme message elements with the warning style.
        view.configureTheme(.warning)
        
        // Add a drop shadow.
        view.configureDropShadow()
        
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        let iconText = ["🤔", "😳", "🙄", "😶"].sm_random()!
        view.configureContent(title: "Warning", body: "Consider yourself warned.", iconText: iconText)
        
        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        
        // Show the message.
        SwiftMessages.show(view: view)
    }
    
    #warning ("Need to pop out to cover tab bar and navigation bar")
    
    @IBAction func addToMyTrip(_ sender: Any) {
        
        guard let selectionViewController = UIStoryboard.searchStoryboard().instantiateViewController(
            withIdentifier: String(describing: TripSelectionViewController.self)
            ) as? TripSelectionViewController else { return }
        
        selectionViewController.location = location
        selectionViewController.tabIndex = tabIndex
        
        self.addChild(selectionViewController)
        
        selectionViewController.view.frame = self.placeInfoCard.frame
        self.view.addSubview(selectionViewController.view)
        selectionViewController.didMove(toParent: self)
    }
    
    @IBAction func closeView(_ sender: Any) {
        removeAnimate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        var touch: UITouch? = touches.first
        
        if touch?.view != placeInfoCard {
            
            removeAnimate()
        }
    }
    
    #warning ("Refactor: gether all alert function together")
    func showAlertWith(title: String?, message: String, style: UIAlertController.Style = .alert) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        //        let okAction = UIAlertAction(title: "OK", style: .default)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.removeAnimate()
        }
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Pop out animation
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished: Bool)  in
            if finished {
                
                self.dismiss(animated: true)
            }
        })
    }
    
    #warning ("Refactor")
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        
        guard let location = location else { return }
        guard let uid = keychain["userId"] else { return }
        
        ref.child("/favorite/\(uid)")
            .queryOrdered(byChild: "position")
            .queryEqual(toValue: location.position)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                if (snapshot.value as? NSDictionary) != nil {
                    
                    self.showAlertWith(title: nil, message: "Already in favorite", style: .alert)
                    
                    /// use SDK to replace alertAction
                    
                } else {
                    
                    self.updateLocation(location: location)
                
                    /// Use tabIndex to pass number for determine tab item
                    
                    if self.tabIndex == 1 {
                    
//                        self.setupMessageView()
                        
                        guard let tripsnavi = self.presentingViewController?.children[0] as? TripNaviViewController else { return }
                        
                        tripsnavi.popViewController(animated: true)
                    } else if self.tabIndex == 2 {
                        
//                        self.setupMessageView()
                        
                        guard let collectionsNavi = self.presentingViewController?.children[1] as? TripNaviViewController else { return }
                        
                        collectionsNavi.popViewController(animated: true)
                    }
                    
                    self.removeAnimate()
                    
                    NotificationCenter.default.post(name: Notification.Name("preserved"), object: nil)
                }
        }
    }
    
    #warning ("Refactor: gether all Firebase relative function together")
    func updateLocation(location: Location) {
        
        guard let uid = keychain["userId"] else { return }
        
        ref.child("/favorite/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            
            self.total = value.allKeys.count
        }
        
        guard let key = ref.child("favorite").childByAutoId().key else { return }
        
        let post = ["addTime": location.addTime,
                    "address": location.address,
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "locationId": key,
                    "name": location.name,
                    "order": location.order,
                    "photo": location.photo,
                    "days": location.days,
                    "position": location.position
            ] as [String: Any]
        
        let postUpdate = ["/favorite/\(uid)/\(key)": post]
        
        ref.updateChildValues(postUpdate)
    }
}
