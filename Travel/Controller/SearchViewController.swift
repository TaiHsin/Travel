//
//  SearchViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/20.
//  Copyright © 2018年 TaiHsinLee. All rights reserved.
//

import UIKit
import GooglePlaces

class SearchViewController: UIViewController {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITableView?

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
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("Place coordinate: \(place.coordinate)")
        print("Place id: \(place.placeID)")
        
        switchDetailVC(place: place)
        
//        loadFirstPhotoForPlace(placeID: place.placeID)
//        nameLabel.text = place.name
    }

    func switchDetailVC(place: GMSPlace) {
        
        /// How to remove childView from parentView?
        
        guard let detailViewController = UIStoryboard.searchStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)) as? DetailViewController else { return }
        
        detailViewController.place = place
        
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
}

/// Wait to modify: pop to new view after tap search result table view for detail information include add function
