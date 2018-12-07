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
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    
    var searchController: UISearchController?
    
    var resultView: UITableView?
    
    let firebaseManager = FirebaseManager()
    
    var location: Location?
    
    var total = 0
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    var tabIndex = 0
    
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
        
        fetchDataCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor.battleshipGrey
    }
    
    func fetchDataCount() {
        
        firebaseManager.fetchDataCount { [weak self] (number) in
            
            self?.total = number
        }
    }
}

// Handle the user's selection.

extension SearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(
        _ resultsController: GMSAutocompleteResultsViewController,
        didAutocompleteWith place: GMSPlace
        ) {
        
        searchController?.isActive = false
    
        convertData(place: place, total: total) { (location) in
            
            self.location = location
            self.switchDetailVC(location: self.location)
        }
    }

    func switchDetailVC(location: Location?) {
        
        /// How to remove childView from parentView?
        
        guard let detailViewController = UIStoryboard.searchStoryboard()
            .instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)
            ) as? DetailViewController else {
                
                return
        }
    
        detailViewController.tabIndex = tabIndex

        detailViewController.location = location

        detailViewController.view.frame = CGRect(
            x: 0,
            y: 0,
            width: fullScreenSize.width,
            height: fullScreenSize.height
        )

        tabBarController?.present(detailViewController, animated: true)
    }
    
    func resultsController(
        _ resultsController: GMSAutocompleteResultsViewController,
        didFailAutocompleteWithError error: Error
        ) {
        
        // TODO: handle the error.
        
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    
    func didRequestAutocompletePredictions(
        _ viewController: GMSAutocompleteViewController
        ) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(
        _ viewController: GMSAutocompleteViewController
        ) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func convertData(place: GMSPlace, total: Int, success: @escaping (Location) -> Void) {
        
        let date = Date()
        
        let dateInt = Double(date.timeIntervalSince1970)
        
        let latitude = place.coordinate.latitude
        
        let longitude = place.coordinate.longitude
        
        let position = "\(latitude)" + "_" + "\(longitude)"
        
        let location = Location.init(
            addTime: dateInt,
            address: place.formattedAddress!,
            latitude: latitude,
            longitude: longitude,
            locationId: "",
            name: place.name,
            order: total + 1,
            photo: place.placeID,
            days: 0,
            position: position
        )
        
        success(location)
    }
}
