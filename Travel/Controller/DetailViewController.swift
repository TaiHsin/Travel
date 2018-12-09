//
//  DetailViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/29.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation
import UIKit

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
    
    private let thDataManager = THDataManager(firebaseManager: FirebaseManager())
    
    private let photoManager = PhotoManager()
    
    private let fullScreenSize = UIScreen.main.bounds.size
    
    var location: Location?
    
    var isFavorite = false
    
    var isMyTrip = false
    
    var tabIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAnimate()
        
        setupViews()
        
        setupPlaceInfoCardContent()
        
        setupButtonConstraints()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch: UITouch? = touches.first
        
        if touch?.view != placeInfoCard, touch?.view != imageCoverView {
            
            removeAnimate()
        }
    }
    
    private func setupViews() {
        
        self.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        
        placeInfoCard.layer.cornerRadius = 8
        
        placeInfoCard.layer.masksToBounds = true
        
        placeImage.clipsToBounds = true
    }
    
    private func setupPlaceInfoCardContent() {
        
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
                
                // TODO: Error handling
                
                print(error)
        })
    }
    
    private func setupButtonConstraints() {
        
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
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        
        guard let location = location else {
            return
        }
        
        addFavorite(location: location)
    }
    
    // Fetch favorite for duplicate check
    private func addFavorite(location: Location) {
        
        thDataManager.checkFavoritelist(
            location: location,
            success: { [weak self] in
                
                self?.updateFavorite(location: location)
    
        },
            failure: { [weak self] (error) in
                
                if error == TravelError.fetchError {
                    
                    self?.showAlertWith()
                }
        })
    }
    
    private func updateFavorite(location: Location) {

        thDataManager.updateFavorite(
            location: location,
            success: { [weak self] in
                
                self?.returnPage()
        },
            failure: { (error) in
                
                print(error.localizedDescription)
                
                // TODO: Error handling
        })
    }
    
    private func returnPage() {
        
        if tabIndex == 1 {
            
            guard let tripsnavi = presentingViewController?.children[0]
                as? TripNaviViewController else {
                    
                    return
            }
            
            tripsnavi.popViewController(animated: true)
            
        } else if tabIndex == 2 {
            
            guard let collectionsNavi = presentingViewController?.children[1]
                as? TripNaviViewController else {
                    
                    return
            }
            
            collectionsNavi.popViewController(animated: true)
        }
        
        NotificationCenter.default.post(name: .collections, object: nil)
        
        removeAnimate()
    }
    
    private func showAlertWith() {
        
        let alertViewController = UIAlertController.showAlert(
            title: nil,
            message: "Already in favorite",
            cancel: false
        ) {
            
            self.removeAnimate()
        }
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    // MARK: - Refactor phase 2 (extension)
    private func showAnimate() {
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        self.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.alpha = 1.0
            
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    private func removeAnimate() {
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            self.view.alpha = 0.0
        }, completion: {(finished: Bool)  in
            
            if finished {
                
                self.dismiss(animated: true)
            }
        })
    }
}
