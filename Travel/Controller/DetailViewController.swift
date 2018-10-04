//
//  DetailViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/29.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import GooglePlaces

class DetailViewController: UIViewController {

    @IBOutlet weak var placeName: UILabel!
    
    @IBOutlet weak var placeImage: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var myTripButton: UIButton!
    
    @IBOutlet weak var placeInfoCard: UIView!
    
    @IBOutlet var detailInfoView: UIView!
    
    var place: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        showAnimate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupButton()
        
        placeInfoCard.layer.cornerRadius = 10
        
        guard let place = place else { return }
        
        placeName.text = place.name
        loadFirstPhotoForPlace(placeID: place.placeID)
        
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
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        
        showAlertWith(title: nil, message: "Added to favorite", style: .alert)
    }
    
    @IBAction func addToMyTrip(_ sender: Any) {
    
        guard let selectionVC = UIStoryboard.searchStoryboard().instantiateViewController(
            withIdentifier: String(describing: TripSelectionViewController.self)
            ) as? TripSelectionViewController else { return }
        
        self.addChild(selectionVC)
        
        selectionVC.view.frame = self.placeInfoCard.frame
        self.view.addSubview(selectionVC.view)
        selectionVC.didMove(toParent: self)
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
    
//    func show() {
//        UIApplication.shared.windows.first?.addSubview(self.view)
//        UIApplication.shared.windows.first?.endEditing(true)
//    }
    
    @IBAction func closeView(_ sender: Any) {
        removeAnimate()
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
