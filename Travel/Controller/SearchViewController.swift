//
//  SearchViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/20.
//  Copyright © 2018年 TaiHsinLee. All rights reserved.
//

import UIKit
import GooglePlaces
import FirebaseDatabase

class SearchViewController: UIViewController {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITableView?
    var ref: DatabaseReference!
    var location: Location?
    var total = 0
    let fullScreenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        
        ref = Database.database().reference()
        
        fetchDataCount { (number) in
            self.total = number
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Put search place and favorite together
//        guard let favoriteVC = UIStoryboard.preservedStoryboard().instantiateViewController(
//            withIdentifier: String(describing: PreservedViewController.self)) as? PreservedViewController else { return }
//
//        self.addChild(favoriteVC)
//
//        favoriteVC.view.frame = self.view.frame
//        self.view.addSubview(favoriteVC.view)
//        favoriteVC.didMove(toParent: self)
    }
}

// Handle the user's selection.

extension SearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(
        _ resultsController: GMSAutocompleteResultsViewController,
        didAutocompleteWith place: GMSPlace
        ) {
        
        searchController?.isActive = false
        
        // Do something with the selected place.
        
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(place.attributions)")
        print("Place coordinate: \(place.coordinate)")
        print("Place id: \(place.placeID)")
        
        /// Remove "total" parameter if is useless
        
        convertData(place: place, total: total) { (location) in
            
            self.location = location
            self.switchDetailVC(location: self.location)
        }
//        loadFirstPhotoForPlace(placeID: place.placeID)
//        nameLabel.text = place.name
    }

    func switchDetailVC(location: Location?) {
        
        /// How to remove childView from parentView?
        
        guard let detailViewController = UIStoryboard.searchStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)) as? DetailViewController else { return }
        
        detailViewController.location = location
        
//        show(detailViewController, sender: nil)
        self.addChild(detailViewController)
    
        self.view.addSubview(detailViewController.view)
        detailViewController.didMove(toParent: self)
        
//        UIApplication.shared.keyWindow?.bringSubviewToFront(detailViewController.view)
    }
    
    func resultsController(
        _ resultsController: GMSAutocompleteResultsViewController,
        didFailAutocompleteWithError error: Error
        ) {
        
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func convertData(place: GMSPlace, total: Int, success: @escaping (Location) -> Void) {
        
        let date = Date()
        let dateInt = Double(date.timeIntervalSince1970)
        
        let latitude = place.coordinate.latitude
        let longitude = place.coordinate.longitude
        
        //        let locationId = CLLocationCoordinate2DMake(latitude, longitude)
        //        let locationString = "\(locationId)"
//        let latitudeStr = String(format: "%.7f", latitude)
//        let longitudeStr = String(format: "%.7f", longitude)
        let locationId = "\(latitude)" + "_" + "\(longitude)"
        
        let location = Location.init(
            addTime: dateInt,
            address: place.formattedAddress!,
            latitude: latitude,
            longitude: longitude,
            locationId: locationId,
            name: place.name,
            order: total + 1,
            photo: place.placeID,
            days: 0
        )
        
        success(location)
    }
    
    func fetchDataCount(success: @escaping (Int) -> Void) {
        
        ref.child("favorite").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? NSDictionary else { return }
            let number = value.allKeys.count
            
            success(number)
        }
    }
}

/// Wait to modify: pop to new view after tap search result table view for detail information include add function
