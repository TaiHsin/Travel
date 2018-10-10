//
//  TripDetailViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/25.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseDatabase
//import MapKit

class TripListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    private let locationManager = CLLocationManager()
    
    let tripsManager = TripsManager()
    
    let photoManager = PhotoManager()

    let decoder = JSONDecoder()
    
    var ref: DatabaseReference!
    
    // Refactor

    var detailData: [Int: [Location]] = [:]
    
    var photo: UIImage?

    var daysArray: [Int] = []

    var totalDays = 0
    
    var daysKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        createDays(total: totalDays)
        
        tripsManager.fetchDayList(daysKey: daysKey) { (location) in
            
//            self.locationArray = location
            
            self.sortLocations(locations: location, total: self.daysArray.count)
            
            self.tableView.reloadData()
        }
    
        setupCollectionView()
        
        setupTableView()
        
        setupLocationManager()
        
        mapView.delegate = self
        
        /// Show day1 markers as default?
        //        showMarker(locations: )
        
        #warning ("Refactor: use enum for all notification strings")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateLocation(noti: )),
            name: Notification.Name("triplist"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// what's diff with leftItemsSupplementBackButton?
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }

    func setupLocationManager() {
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func searchLocation(_ sender: UIBarButtonItem) {

        showAlertWith()
    }
    
    func setupTableView() {
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        let xib = UINib(
            nibName: String(describing: TripListTableViewCell.self),
            bundle: nil
        )
        
        tableView.register(
            xib,
            forCellReuseIdentifier: String(describing: TripListTableViewCell.self)
        )
        
        let xibEmpty = UINib(
            nibName: String(describing: EmptyTableViewCell.self),
            bundle: nil
        )
        
        tableView.register(
            xibEmpty,
            forCellReuseIdentifier: String(describing: EmptyTableViewCell.self)
        )
    }
    
    func setupCollectionView() {
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.allowsSelection = true
        
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
    
    func showMarker(locations: [Location]) {
        
        mapView.clear()
        var bounds = GMSCoordinateBounds()
        
        for data in locations {
            
            let latitude = data.latitude
            let longitude = data.longitude
            
            let position = CLLocationCoordinate2DMake(latitude, longitude)
            let marker = GMSMarker(position: position)
            marker.title = data.name
            marker.map = mapView
            
            // Fit all markers in map camera
            bounds = bounds.includingCoordinate(marker.position)
            let update = GMSCameraUpdate.fit(bounds)
            mapView.animate(with: update)
        }
    }
    
    func switchDetailVC(location: Location) {
 
        guard let detailViewController = UIStoryboard.searchStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)) as? DetailViewController else { return }
        
        detailViewController.location = location
        
        self.addChild(detailViewController)
        
        detailViewController.view.frame = self.view.frame
        self.view.addSubview(detailViewController.view)
        detailViewController.didMove(toParent: self)
    }
    
    @objc func updateLocation(noti: Notification) {
        
//        locationArray.removeAll()
        detailData.removeAll()
        
        tripsManager.fetchDayList(daysKey: daysKey) { (location) in
            
//            self.locationArray = location
            
            self.sortLocations(locations: location, total: self.daysArray.count)
            
            self.tableView.reloadData()
        }
    }
    
    #warning ("Refact to alert manager")
    
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
    
    // create days array depend on passed days
    
    func createDays(total days: Int) {
        
        for index in 1 ... days {
            daysArray.append(index)
        }
        print(daysArray)
        return
    }
    
    /// Get data and sort locally
    func sortLocations(locations: [Location], total: Int) {
        
        var data: [Int: [Location]] = [:]
        var dataArray: [[Location]] = []
        
        // better way to avoid for loops?
        for _ in 1 ... total {
            dataArray.append([])
        }
        
        for index in 0 ..< locations.count {

            for key in 1 ... total {
                if locations[index].days == key {
                    
                    let item = locations[index]
                    dataArray[key - 1].append(item)
                    data[key] = dataArray[key - 1]
                }
            }
        }

        // Sort array by order property
        for number in 1 ... total {
            data[number]?.sort(by: {$0.order < $1.order})
        }
        
        self.detailData = data
        print(detailData)
    }
    
//    func parseData(details: [String: Any]) {
//
//        // Get days
//
//        for key in details.keys {
//            detailDays.append(key)
//        }
//
//        print(detailDays)
//
//        sortedDays = detailDays.sorted { (first, second) -> Bool in
//
//            let firstIndex = first.index(first.startIndex, offsetBy: 3)
//            let firstKeyValue = Int(String(first[firstIndex...]))
//
//            let secondIndex = second.index(second.startIndex, offsetBy: 3)
//            let secondKeyValue = Int(String(second[secondIndex...]))
//
//            return firstKeyValue! < secondKeyValue!
//        }
//
//        print(sortedDays)
//        collectionView.reloadData()
//
//        guard let data = details[sortedDays[0]] as? [String: Any] else { return }
//        print(data)
//
//        var sortedData = [Any]()
//        for data in data {
//            sortedData.append(data.value)
//        }
//        print(sortedData)
//    }

    /// Get locations by day
    func fetchDailyLocation(
        day: Int,
        success: @escaping ([Location]) -> Void) {
        
        var location: [Location] = []
        
        ref.child("tripDays")
            .child("\(daysKey)")
            .queryOrdered(byChild: "days")
            .queryEqual(toValue: day)
            .observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? NSDictionary else { return }
            
            print(value.allValues)
            
            for value in value.allValues {
                guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else { return }
                
                do {
                    let data = try self.decoder.decode(Location.self, from: jsonData)
                    
                    location.append(data)
                    
                } catch {
                    print(error)
                }
            }
            
            success(location)
        }
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

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return daysArray.count
    }
    
    #warning ("Refactor: replace by enum")
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
        guard let tripData = detailData[section + 1] else { return 1 }
        guard tripData.count != 0 else {
            return 1
        }
        return tripData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // possible nil??
        guard let datas = detailData[indexPath.section + 1], datas.count != 0 else {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: EmptyTableViewCell.self),
                for: indexPath
            )
            
            guard let emptyCell = cell as? EmptyTableViewCell else { return cell}
            
            return emptyCell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: TripListTableViewCell.self),
            for: indexPath
        )
        
        guard let listCell = cell as? TripListTableViewCell,
              indexPath.row < datas.count else {
                
                return cell
        }
        
        #warning ("Refactor: seems will delay, better way?")
        let placeId = datas[indexPath.row].photo
        photoManager.loadFirstPhotoForPlace(placeID: placeId) { (photo) in
            
            listCell.listImage.image = photo
        }
        
        listCell.placeNameLabel.text = datas[indexPath.row].name
        listCell.addressLabel.text = datas[indexPath.row].address
        
        return listCell
    }
}

// MARK: - Table View Delegate

extension TripListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        
        let label = UILabel()
        label.text = String(describing: daysArray[section])

        label.frame = CGRect(x: 5, y: 2.5, width: 200, height: 30)
        label.textColor = UIColor.white
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(indexPath.section)
        
        guard let locationArray = detailData[indexPath.section + 1] else { return }
        let location = locationArray[indexPath.row]
        switchDetailVC(location: location)
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
        ) {
        
        if editingStyle == .delete {
            
            guard let locationArray = detailData[indexPath.section + 1] else { return }
            let location = locationArray[indexPath.row]
            deletaData(daysKey: daysKey, location: location, indexPath: indexPath)
            
            detailData[indexPath.section + 1]!.remove(at: indexPath.row)
            
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

// MARK: - Collection View Data Source

extension TripListViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
        
        return daysArray.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: MenuBarCollectionViewCell.self),
            for: indexPath)
        
        guard let dayTitleCell = cell as? MenuBarCollectionViewCell,
            indexPath.row < daysArray.count else {
                
                return cell
        }
        
        dayTitleCell.dayLabel.text = String(daysArray[indexPath.item])
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tableViewIndexPath = IndexPath(row: 0, section: indexPath.row)
        tableView.scrollToRow(at: tableViewIndexPath, at: .top, animated: true)

        guard let locations = detailData[indexPath.row + 1] else { return }
        
        showMarker(locations: locations)
    }
    
    func deletaData(daysKey: String, location: Location, indexPath: IndexPath) {

        ref.child("tripDays")
            .child(daysKey)
            .queryOrdered(byChild: "locationId")
            .queryEqual(toValue: location.locationId)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else { return }
                guard let key = value.allKeys.first as? String else { return }
                self.ref.child("/tripDays/\(daysKey)/\(key)").removeValue()
                
                self.changeOrder(daysKey: daysKey, indexPath: indexPath, location: location)
        }
    }
    
    func changeOrder(daysKey: String, indexPath: IndexPath, location: Location) {

        let total = tableView.numberOfRows(inSection: indexPath.section)
        let days = location.days
        guard let locationArray = detailData[days] else { return }
        
        // use allKey and locationId to compare and change order
        
        for location in locationArray {
         
            if location.order > indexPath.row + 1 {
             
                let newOrder = location.order - 1
                let key = location.locationId
                let postUpdate = ["/tripDays/\(daysKey)/\(key)/order": newOrder]
                ref.updateChildValues(postUpdate)
            }
        }
    }
    
    func updatLocation(location: Location) {
        
        guard let key = ref.child("tripDays").childByAutoId().key else { return }
        
        let post = ["addTime": location.addTime,
                    "address": location.address,
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "locationId": key,
                    "name": location.name,
                    "order": location.order,
                    "photo": location.photo,
                    "days": location.days
            ] as [String: Any]
        
        let postUpdate = ["/tripDays/\(daysKey)/\(key)": post]
        
        ref.updateChildValues(postUpdate)
    }
    
    // Waiting for merge
    func deleteData(location: Location) {
        
        ref.child("favorite")
            .queryOrdered(byChild: "locationId")
            .queryEqual(toValue: location.locationId)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else { return }
                guard let key = value.allKeys.first as? String else { return }
                self.ref.child("/favorite/\(key)").removeValue()
        }
    }
}
/// Refactor: seperate collection view/ mapview/ table view to different controller?
