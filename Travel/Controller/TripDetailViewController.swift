//
//  TripDetailViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/25.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import GoogleMaps
//import MapKit

class TripDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    private let locationManager = CLLocationManager()
    
    private let locationData = LocationData()
    
    var photo: UIImage?
    var days: [String] = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6"]
    var dates: [String] = ["Nov. 20", "Nov. 21", "Nov. 22", "Nov. 23", "Nov. 24", "Nov. 25"]
    
    override func loadView() {
        super.loadView()
        
        addMarker(latitude: locationData.latitude, longitude: locationData.longitude)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
    }
    
    func setupCollectionView() {
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        collectionView.showsHorizontalScrollIndicator = false
        
        let identifier = String(describing: MenuBarCollectionViewCell.self)
        
        let xib = UINib(nibName: identifier, bundle: nil)
        
        collectionView.register(xib, forCellWithReuseIdentifier: identifier)
    }
    
    // MapView
    
    // Locate device location and show location button
    func getCurrentLocation() {
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
    }
    
    func fetchPlaces() {
        
    }
    
    func addMarker(latitude: Double, longitude: Double) {
        
        let position = CLLocationCoordinate2DMake(latitude, longitude)
        let marker = GMSMarker(position: position)
        marker.title = locationData.placeName
        
        marker.map = mapView
    }
}

// MARK: = CLLocationManagerDelegate

extension TripDetailViewController: CLLocationManagerDelegate {
    
    // didChangeAuthorization function is called when the user grants or revokes location permissions.
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse else { return }
        
        getCurrentLocation()
    }
    
    // didUpdateLocations function executes when the location manager receives new location data
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        if locationData.latitude == nil && locationData.longitude == nil {
            
            getCurrentLocation()
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 1, bearing: 0, viewingAngle: 0)
        } else {
            
            let coordinate = CLLocationCoordinate2DMake(locationData.latitude, locationData.longitude)
            mapView.camera = GMSCameraPosition(target: coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
        }
        
        locationManager.stopUpdatingLocation()
    }
}

extension TripDetailViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
}

// MARK: - Collection View Data Source

extension TripDetailViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
        return 6
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: MenuBarCollectionViewCell.self),
            for: indexPath)
        
        guard let dayTitleCell = cell as? MenuBarCollectionViewCell, indexPath.row < 6 else { return cell }
        
        dayTitleCell.dayLabel.text = days[indexPath.row]
        dayTitleCell.dateLabel.text = dates[indexPath.item]
        
        return dayTitleCell
    }
}

// MARK: - Collection View Delegate Flow Layout

extension TripDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
        ) -> CGFloat {
        
        return 0
    }
}
