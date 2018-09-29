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

class TripListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    private let locationManager = CLLocationManager()

    var locationData = [LocationData]()

    var photo: UIImage?

    var days: [String] = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6"]

    var dates: [String] = ["Nov. 20", "Nov. 21", "Nov. 22", "Nov. 23", "Nov. 24", "Nov. 25"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        setupTableView()
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        
        locationData = [LocationData(placeName: "Effel Tower", photo: #imageLiteral(resourceName: "paris"), address: "91A Rue de Rivoli, 75001 Paris, France", latitude: 48.858539, longitude: 2.294524),
                        LocationData(placeName: "Arc de Triomphe", photo: #imageLiteral(resourceName: "Arc_de_Triomphe"), address: "Place Charles de Gaulle, 75008 Paris, France", latitude: 48.873982, longitude: 2.295457),
                        LocationData(placeName: "Notre-Dame de Paris", photo: #imageLiteral(resourceName: "notre_dame_de_paris"), address: "6 Parvis Notre-Dame - Pl. Jean-Paul II, 75004 Paris, France", latitude: 48.853116, longitude: 2.349924),
                        LocationData(placeName: "Palais du Louvre", photo: #imageLiteral(resourceName: "palais_du_louvre"), address: "91A Rue de Rivoli, 75001 Paris, France", latitude: 48.860533, longitude: 2.338588)
        ]
        
        addMarker(data: locationData)
    }
    
    @IBAction func searchLocation(_ sender: UIBarButtonItem) {

        showAlertWith()
    }
    
    func setupTableView() {
        
        let xib = UINib(
            nibName: String(describing: TripListTableViewCell.self),
            bundle: nil
        )
        
        tableView.register(
            xib,
            forCellReuseIdentifier: String(describing: TripListTableViewCell.self)
        )
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupCollectionView() {
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        collectionView.showsHorizontalScrollIndicator = false
        
        let identifier = String(describing: MenuBarCollectionViewCell.self)
        
        let xib = UINib(nibName: identifier, bundle: nil)
        
        collectionView.register(xib, forCellWithReuseIdentifier: identifier)
    }
    
    // MARK: - Google Map View
    
    // Locate device location and show location button
    func getCurrentLocation() {
        locationManager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        
//        mapView.settings.myLocationButton = true
    }
    
    func fetchPlaces() {
        
    }
    
    func addMarker(data: [LocationData]) {
        
        for locationData in data {
            
            let latitude = locationData.latitude
            let longitude = locationData.longitude
            
            let position = CLLocationCoordinate2DMake(latitude, longitude)
            let marker = GMSMarker(position: position)
            marker.title = locationData.placeName

            marker.map = mapView
            mapView.camera = GMSCameraPosition(target: position, zoom: 12, bearing: 0, viewingAngle: 0)
            
            /// Need to use GMSCoordinateBounds to show all markers
        }
    }
    
    func showAlertWith() {

        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in

        }

        let favoriteAction = UIAlertAction(title: "Add from favorite ", style: .default) { (_) in
            
            let tabController = self.view.window?.rootViewController as? UITabBarController
            tabController?.dismiss(animated: false, completion: nil)
            tabController?.selectedIndex = 1
        }
        
        let searchAction = UIAlertAction(title: "Search places", style: .default) { (_) in
            
            guard let controller = UIStoryboard.searchStoryboard()
                .instantiateViewController(
                    withIdentifier: String(describing: SearchViewController.self)
                ) as? SearchViewController else { return }
            
            self.show(controller, sender: nil)
        }
        
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(favoriteAction)
        actionSheetController.addAction(searchAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
}

// MARK: - CLLocationManagerDelegate

extension TripListViewController: CLLocationManagerDelegate {
    
    // didChangeAuthorization function is called when the user grants or revokes location permissions.
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse else { return }
        
        getCurrentLocation()
    }
    
    // didUpdateLocations function executes when the location manager receives new location data
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        guard let location = locations.last else { return }
//
//        if locationData.latitude == nil && locationData.longitude == nil {
//
//            getCurrentLocation()
//            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 1, bearing: 0, viewingAngle: 0)
//        } else {
//
//            let coordinate = CLLocationCoordinate2DMake(locationData.latitude, locationData.longitude)
//            mapView.camera = GMSCameraPosition(target: coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
//
//        }
//
//        locationManager.stopUpdatingLocation()
//    }
}

// MARK: - GMS Map View Delegate

extension TripListViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
}

// MARK: - Tabel View Data Source

extension TripListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationData.count
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        
//        return days[section]
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        
        let label = UILabel()
        label.text = days[section] + " " + dates[section]
        label.frame = CGRect(x: 5, y: 2.5, width: 200, height: 30)
        label.textColor = UIColor.white
        view.addSubview(label)

        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: TripListTableViewCell.self),
            for: indexPath
        )
        
        guard let listCell = cell as? TripListTableViewCell,
              indexPath.row < locationData.count else {
                
                return cell
        }
        
        listCell.listImage.image = locationData[indexPath.row].photo
        listCell.placeNameLabel.text = locationData[indexPath.row].placeName
        listCell.addressLabel.text = locationData[indexPath.row].address
        
        return listCell
    }
}

// MARK: - Table View Delegate

extension TripListViewController: UITableViewDelegate {
    
}

// MARK: - Collection View Data Source

extension TripListViewController: UICollectionViewDataSource {
    
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
        
        return dayTitleCell
    }
}

// MARK: - Collection View Delegate Flow Layout

extension TripListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
        ) -> CGFloat {
        
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        
        return CGSize(width: 55, height: 30)
    }
}




/// Refactor: seperate collection view/ mapview/ table view to different controller?
/// Map cemare adjust to show all markers
