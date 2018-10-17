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
        
        if isMyTrip {
            
            let width = myTripsButtonWidthConstraints.constant
            myTripsButtonWidthConstraints.constant = 0.0
            favoriteButtonWidthConstraints.constant += width
            intervalConstraints.constant = 0.0
        } else if isFavorite {
            
            let width = favoriteButtonWidthConstraints.constant
            favoriteButtonWidthConstraints.constant = 0.0
            myTripsButtonWidthConstraints.constant += width
            intervalConstraints.constant = 0.0
        }
        
//        detailInfoView.frame = CGRect(x: 0, y: 0, width: fullScreenSize.width, height: fullScreenSize.height)
//        detailInfoView.layer.shouldRasterize = true
//        detailInfoView.layer.rasterizationScale = UIScreen.main.scale
        
        #warning ("below shouldn't in viewWillAppear")
        
        guard let location = location else { return }
        let placeId = location.photo
        
        placeName.text = location.name
        positionLabel.text = location.address
        
        photoManager.loadFirstPhotoForPlace(placeID: placeId, success: { (photo) in
            
            self.placeImage.image = photo
        }, failure: { (error) in
            // TODO:
            })
      
//        UIApplication.shared.keyWindow?.bringSubviewToFront(detailInfoView)
    }
    
    #warning ("Need to pop out to cover tab bar and navigation bar")
    
    @IBAction func addToMyTrip(_ sender: Any) {
        
        guard let selectionViewController = UIStoryboard.searchStoryboard().instantiateViewController(
            withIdentifier: String(describing: TripSelectionViewController.self)
            ) as? TripSelectionViewController else { return }
        
        selectionViewController.location = location
        
        self.addChild(selectionViewController)
        
        selectionViewController.view.frame = self.placeInfoCard.frame
        self.view.addSubview(selectionViewController.view)
        selectionViewController.didMove(toParent: self)
    }
    
    //    func show() {
    //        UIApplication.shared.windows.first?.addSubview(self.view)
    //        UIApplication.shared.windows.first?.endEditing(true)
    //    }
    
    @IBAction func closeView(_ sender: Any) {
        removeAnimate()
    }
    
    #warning ("Refactor: gether all alert function together")
    func showAlertWith(title: String?, message: String, style: UIAlertController.Style = .alert) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
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
//                self.view.removeFromSuperview()
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
                    
                } else {
                    
                    // Didn't find location in Firebase
                    self.updateLocation(location: location)
                    self.showAlertWith(title: nil, message: "Added to favorite", style: .alert)
                    
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
