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
    
    @IBOutlet weak var imageCoverView: UIView!
    
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
    
    let dateFormatter = DateFormatter()
    
    var total = 0
    
    var location: Location?
    
    var isFavorite = false
    
    var isMyTrip = false
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    var tabIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        showAnimate()
        
        self.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        
        placeInfoCard.layer.cornerRadius = 8
        
        placeInfoCard.layer.masksToBounds = true
        
        placeImage.clipsToBounds = true
        
        let width = placeInfoCard.frame.width
        
        myTripsButtonWidthConstraints = myTripButton
            .widthAnchor
            .constraint(equalToConstant: width * 0.5)
        
        myTripsButtonWidthConstraints.isActive = true
        
        favoriteButtonWidthConstraints = favoriteButton
            .widthAnchor
            .constraint(equalToConstant: width - width * 0.5)
        
        favoriteButtonWidthConstraints.isActive = true
        
        if isMyTrip || tabIndex == 2 {
            
            myTripsButtonWidthConstraints.constant = 0.0
            
            favoriteButtonWidthConstraints.constant = width
            
            intervalConstraints.constant = 0.0
        } else if isFavorite || tabIndex == 1 {
            
            favoriteButtonWidthConstraints.constant = 0.0
            
            myTripsButtonWidthConstraints.constant = width
            
            intervalConstraints.constant = 0.0
        }
        
        guard let location = location else {
            
            return
        }
        
        let placeId = location.photo
        
        placeName.text = location.name
        
        positionLabel.text = location.address
        
        photoManager.loadFirstPhotoForPlace(
            placeID: placeId,
            success: { [weak self] (photo) in
                
                self?.placeImage.image = photo
                
            }, failure: { (error) in
                
                // TODO:
                
                print(error)
        })
    }
    
    @IBAction func addToMyTrip(_ sender: Any) {
        
        guard let selectionViewController = UIStoryboard.searchStoryboard()
            .instantiateViewController(
            withIdentifier: String(describing: TripSelectionViewController.self)
            ) as? TripSelectionViewController else {
                
                return
        }
        
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
        
        let touch: UITouch? = touches.first
        
        if touch?.view != placeInfoCard, touch?.view != imageCoverView {
            
            removeAnimate()
        }
    }
    
    func showAlertWith() {
        
        let alertViewController = UIAlertController.showAlert(
        title: nil,
        message: "Already in favorite",
        cancel: false
        ) {
            
            self.removeAnimate()
        }
        
        self.present(alertViewController, animated: true, completion: nil)
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
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        
        guard let location = location else { return }
        
        guard let uid = keychain["userId"] else { return }
        
        ref.child("/favorite/\(uid)")
            .queryOrdered(byChild: "position")
            .queryEqual(toValue: location.position)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                if (snapshot.value as? NSDictionary) != nil {
                    
                    self.showAlertWith()
                    
                    // use SDK to replace alertAction
                    
                } else {
                    
                    self.updateLocation(location: location)
                    
                    if self.tabIndex == 1 {
                        
                        guard let tripsnavi = self.presentingViewController?.children[0]
                            as? TripNaviViewController else {
                                
                                return
                        }
                        
                        tripsnavi.popViewController(animated: true)
                    } else if self.tabIndex == 2 {
                        
                        guard let collectionsNavi = self.presentingViewController?.children[1]
                            as? TripNaviViewController else {
                                
                                return
                        }
                        
                        collectionsNavi.popViewController(animated: true)
                    }
                    
                    self.removeAnimate()
                    
                    NotificationCenter.default.post(name: .collections, object: nil)
                }
        }
    }
    
    func updateLocation(location: Location) {
        
        guard let uid = keychain["userId"] else {
            
            return
        }
        
        ref.child("/favorite/\(uid)").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            
            guard let value = snapshot.value as? NSDictionary else {
                
                return
            }
            
            self?.total = value.allKeys.count
        }
        
        guard let key = ref.child("favorite").childByAutoId().key else {
            
            return
        }
        
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
