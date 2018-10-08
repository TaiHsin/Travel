//
//  DetailViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/29.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import GooglePlaces
import FirebaseDatabase
import Firebase

class DetailViewController: UIViewController {
    
    @IBOutlet weak var placeName: UILabel!
    
    @IBOutlet weak var placeImage: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var myTripButton: UIButton!
    
    @IBOutlet weak var placeInfoCard: UIView!
    
    @IBOutlet var detailInfoView: UIView!
    
    var ref: DatabaseReference!
    
    let dateFormatter = DateFormatter()
    
    var total = 0
    
    var place: GMSPlace?
    
    var location: Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        showAnimate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        placeInfoCard.layer.cornerRadius = 10
        
        setupButton()
        
        #warning ("below shouldn't in viewWillAppear")
        
        guard let location = location else { return }
        placeName.text = location.name
        loadFirstPhotoForPlace(placeID: location.photo)
        
        UIApplication.shared.keyWindow?.bringSubviewToFront(detailInfoView)
    }
    
    func setupButton() {
        
        favoriteButton.layer.borderWidth = 1
        favoriteButton.layer.borderColor = UIColor.darkGray.cgColor
        
        favoriteButton.layer.cornerRadius = 10
        favoriteButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        myTripButton.layer.borderWidth = 1
        myTripButton.layer.borderColor = UIColor.darkGray.cgColor
        
        myTripButton.layer.cornerRadius = 10
        myTripButton.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    
    #warning ("Refactor")
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        
//        let date = Date()
//        let dateInt = Double(date.timeIntervalSince1970)
//        
//        guard let latitude = place?.coordinate.latitude else { return }
//        guard let longitude = place?.coordinate.longitude else { return }
//        
//        //        let locationId = CLLocationCoordinate2DMake(latitude, longitude)
//        //        let locationString = "\(locationId)"
//        let latitudeStr = String(format: "%.7f", latitude)
//        let longitudeStr = String(format: "%.7f", longitude)
//        let locationId = "\(latitudeStr)" + "_" + "\(longitudeStr)"
//        
//        let location = Location.init(
//            addTime: dateInt,
//            address: (place?.formattedAddress)!,
//            latitude: latitude,
//            longitude: longitude,
//            locationId: locationId,
//            name: (place?.name)!,
//            order: 1,
//            photo: (place?.placeID)!
//        )
        guard let location = location else { return }
        
        ref.child("/favorite/")
            .queryOrdered(byChild: "locationId")
            .queryEqual(toValue: location.locationId)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                if (snapshot.value as? NSDictionary) != nil {
                    
                    // alert view to notify
                    print("-------------------------")
                    print("Already in your favorite!")
                    print("-------------------------")
                    
                } else {
                    // Notify view but not with alert view
                    // Didn't find location in Firebase
                    self.updateLocation(location: location)
                    self.showAlertWith(title: nil, message: "Added to favorite", style: .alert)
                    
                    NotificationCenter.default.post(name: Notification.Name("update"), object: nil)
                }
        }
    }
    
    // Need to pop out to cover tab bar and navigation bar
    @IBAction func addToMyTrip(_ sender: Any) {
        
        guard let selectionVC = UIStoryboard.searchStoryboard().instantiateViewController(
            withIdentifier: String(describing: TripSelectionViewController.self)
            ) as? TripSelectionViewController else { return }
        
        self.addChild(selectionVC)
        
        selectionVC.view.frame = self.placeInfoCard.frame
        self.view.addSubview(selectionVC.view)
        selectionVC.didMove(toParent: self)
    }
    
    //    func show() {
    //        UIApplication.shared.windows.first?.addSubview(self.view)
    //        UIApplication.shared.windows.first?.endEditing(true)
    //    }
    
    @IBAction func closeView(_ sender: Any) {
        removeAnimate()
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
            }
        }
    }

    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: { (photo, error)
            -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.placeImage.image = photo
                
                //  self.imageView.image = photo;
                //  self.attributionTextView.attributedText = photoMetadata.attributions;
            }
        })
    }
    
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
                self.view.removeFromSuperview()
            }
        })
    }
}

extension DetailViewController {
    
    func updateLocation(location: Location) {
    
        ref.child("favorite").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            
            self.total = value.allKeys.count
        }
    
        guard let key = ref.child("favorite").childByAutoId().key else { return }
 
        let post = ["addTime": location.addTime,
                    "address": location.address,
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "locationId": location.locationId,
                    "name": location.name,
                    "order": location.order,
                    "photo": location.photo,
                    "days": location.days
            ] as [String: Any]
        
        let postUpdate = ["/favorite/\(key)": post]
        
        ref.updateChildValues(postUpdate)

    }
}
