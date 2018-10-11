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
import Crashlytics
//import MapKit

struct Path {
    
    static var initialIndexPath: IndexPath?
    
    static var cellSnapShot: UIView?
}

enum Modify {
    case add, delete
}

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
    
    var name = ""

    var totalDays = 0
    
    var daysKey = ""
    
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        createDays(total: totalDays)
        
        tripsManager.fetchDayList(daysKey: daysKey) { (location) in
            
            self.sortLocations(locations: location, total: self.daysArray.count)
            
            self.tableView.reloadData()
        }
    
        /// Disable in v1.0 due to bug
        // setup long press gesture
//        let longPress = UILongPressGestureRecognizer(
//            target: self,
//            action: #selector(longPressGestureRecognized(gestureRecognizer: ))
//        )
//        self.tableView.addGestureRecognizer(longPress)
        
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
        
        let button = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
        button.setTitle("Crash", for: [])
        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)

    }
    
    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// what's diff with leftItemsSupplementBackButton?
        navigationItem.hidesBackButton = true
        navigationItem.title = name
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
        
        /// Empty cell ( disable for swap cell issue)
//        let xibEmpty = UINib(
//            nibName: String(describing: EmptyTableViewCell.self),
//            bundle: nil
//        )
//
//        tableView.register(
//            xibEmpty,
//            forCellReuseIdentifier: String(describing: EmptyTableViewCell.self)
//        )
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
        
        detailData.removeAll()
        
        tripsManager.fetchDayList(daysKey: daysKey) { (location) in
            
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
        
        for index in 0 ... days - 1 {
            daysArray.append(index)
        }
        print(daysArray)
        return
    }
    
    // Get data and sort locally
    func sortLocations(locations: [Location], total: Int) {
        
        var data: [Int: [Location]] = [:]
        var dataArray: [[Location]] = []
        
        // better way to avoid for loops?
        for _ in 0 ... total - 1 {
            dataArray.append([])
        }
        
        for index in 0 ..< locations.count {

            for key in 0 ... total - 1 {
                if locations[index].days == key + 1 {
                    
                    let item = locations[index]
                    dataArray[key].append(item)
                    data[key] = dataArray[key]
                }
            }
        }

        // Sort array by order property
        for number in 0 ... total - 1 {
            data[number]?.sort(by: {$0.order < $1.order})
        }
        
        self.detailData = data
        print(detailData)
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
 
        guard let tripData = detailData[section] else { return 0 }
        guard tripData.count != 0 else {
            return 0
        }
        return tripData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // possible nil??
        guard let datas = detailData[indexPath.section], datas.count != 0 else {
            
            /// Empty cell
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: String(describing: TripListTableViewCell.self),
//                for: indexPath
//            )
//            guard let emptyCell = cell as? TripListTableViewCell else { return UITableViewCell() }
//
//            emptyCell.flag = false
//            emptyCell.switchCellContent()
//            emptyCell.selectionStyle = .none
//
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: TripListTableViewCell.self),
            for: indexPath
        )
        
        guard let listCell = cell as? TripListTableViewCell,
              indexPath.row < datas.count else {
                
                return cell
        }
        
        listCell.flag = true
        listCell.switchCellContent()
        
        #warning ("Refactor: seems will delay, better way?")
        let placeId = datas[indexPath.row].photo
        photoManager.loadFirstPhotoForPlace(placeID: placeId) { (photo) in
            
            listCell.listImage.image = photo
        }
        
        listCell.placeNameLabel.text = datas[indexPath.row].name
        listCell.addressLabel.text = datas[indexPath.row].address
        
        listCell.selectionStyle = .none
        //        cell.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        //        cell.setSelected(true, animated: true)
        return listCell
    }
}

// MARK: - Table View Delegate

extension TripListViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
        ) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        
        let label = UILabel()
        label.text = String(describing: daysArray[section] + 1)

        label.frame = CGRect(x: 5, y: 2.5, width: 200, height: 30)
        label.textColor = UIColor.white
        view.addSubview(label)
        
        return view
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
        ) -> CGFloat {
        
        return 35
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        
        guard let locationArray = detailData[indexPath.section] else { return }
        let location = locationArray[indexPath.row]
        switchDetailVC(location: location)
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
        ) {
        
        if editingStyle == .delete {
            
            guard let locationArray = detailData[indexPath.section] else { return }
            let location = locationArray[indexPath.row]
            deletaData(daysKey: daysKey, location: location)
            changeOrder(daysKey: daysKey, indexPath: indexPath, location: location, type: .delete)
            
            detailData[indexPath.section]!.remove(at: indexPath.row)
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
        
        dayTitleCell.dayLabel.text = String(daysArray[indexPath.item] + 1)
        
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

        guard let locations = detailData[indexPath.row] else { return }
        
        showMarker(locations: locations)
    }
    
    func deletaData(daysKey: String, location: Location) {

        ref.child("tripDays")
            .child(daysKey)
            .queryOrdered(byChild: "locationId")
            .queryEqual(toValue: location.locationId)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else { return }
                guard let key = value.allKeys.first as? String else { return }
                self.ref.child("/tripDays/\(daysKey)/\(key)").removeValue()
        }
    }
    
    func updateData(daysKey: String, indexPath: IndexPath, location: Location) {
        
        let days = indexPath.section + 1
        let order = indexPath.row
        
        let orderUpdate = ["/tripDays/\(self.daysKey)/\(location.locationId)/order": order]
        self.ref.updateChildValues(orderUpdate)
        
        let daysUpdate = ["/tripDays/\(self.daysKey)/\(location.locationId)/days": days]
        self.ref.updateChildValues(daysUpdate)
    }
    
    func changeOrder(daysKey: String, indexPath: IndexPath, location: Location, type: Modify) {

        let days = indexPath.section + 1
        guard let locationArray = detailData[days - 1] else { return }
        
        // Compare other data order to update
        for item in locationArray {
         
            switch type {
                
            case .delete:
                if item.order >= indexPath.row, item.locationId != location.locationId {
                    
                    let newOrder = item.order - 1
                    let key = item.locationId
                    let postUpdate = ["/tripDays/\(daysKey)/\(key)/order": newOrder]
                    ref.updateChildValues(postUpdate)
                }

            case .add:
                if item.order >= indexPath.row, item.locationId != location.locationId {
                
                let newOrder = item.order + 1
                let key = item.locationId
                let postUpdate = ["/tripDays/\(daysKey)/\(key)/order": newOrder]
                ref.updateChildValues(postUpdate)
                }
            }
        }
    }

    func updateAllData(daysKey: String, total: Int, datas: [Int: [Location]]) {
        
        for day in 0 ... total - 1 {
            
            datas[day]?.forEach({ (location) in
                
                let key = location.locationId
                
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
                
                let postUpdate = ["/tripDays/\(self.daysKey)/\(key)": post]
                self.ref.updateChildValues(postUpdate)
            })
        }
    }
}

// MARK: - Long press gesture to swap table view cell

extension TripListViewController {
    
    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        
        guard let longPress = gestureRecognizer as? UILongPressGestureRecognizer else { return }
        
        let state = longPress.state
        
        let locationInView = longPress.location(in: self.tableView)
        
        let indexPath = self.tableView.indexPathForRow(at: locationInView)
    
        switch state {
            
        case .began:
            
            guard indexPath != nil else { return }
            
                Path.initialIndexPath = indexPath
                guard let cell = self.tableView.cellForRow(at: indexPath!) as? TripListTableViewCell else { return }
            
                Path.cellSnapShot = snapshotOfCell(inputView: cell)
                var center = cell.center
                Path.cellSnapShot?.center = center
                Path.cellSnapShot?.alpha = 0.0
                self.tableView.addSubview(Path.cellSnapShot!)
                
                UIView.animate(withDuration: 0.25, animations: {
                    center.y = locationInView.y
                    Path.cellSnapShot?.center = center
                    Path.cellSnapShot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    Path.cellSnapShot?.alpha = 0.98
                    cell.alpha = 0.0
                    
                }, completion: { (finished) in
                    if finished {
                        cell.isHidden = true
                    }
                })
            
        case .changed:
            
            var center = Path.cellSnapShot?.center
            center?.y = locationInView.y
            Path.cellSnapShot?.center = center!
            
            guard let indexPath = indexPath, indexPath != Path.initialIndexPath else { return }
            guard let firstIndexPath = Path.initialIndexPath else { return }

            let firstDay = firstIndexPath.section
            let secondDay = indexPath.section
            
            if firstDay == secondDay {

                // swap order
                let firstOrder = detailData[firstDay]![firstIndexPath.row].order
                detailData[firstDay]![firstIndexPath.row].order = detailData[secondDay]![indexPath.row].order
                detailData[secondDay]![indexPath.row].order = firstOrder
                
                let data = detailData[firstDay]![firstIndexPath.row]
                detailData[firstDay]![firstIndexPath.row] = detailData[secondDay]![indexPath.row]
                detailData[secondDay]![indexPath.row] = data
                
            } else if firstDay < secondDay {
            
                let data = detailData[firstDay]![firstIndexPath.row]
                detailData[firstDay]?.remove(at: firstIndexPath.row)
                
                let total = tableView.numberOfRows(inSection: secondDay)
                
                for index in 0 ... total - 1 {
                    detailData[secondDay]![index].order += 1
                }
                
                detailData[secondDay]?.insert(data, at: 0)
                detailData[secondDay]?[0].order = 0
                detailData[secondDay]?[0].days = secondDay + 1
                
            } else if firstDay > secondDay {
                
                let data = detailData[firstDay]![firstIndexPath.row]
                detailData[firstDay]?.remove(at: firstIndexPath.row)
                
                let total = tableView.numberOfRows(inSection: firstDay)
                
                for index in 0 ... total - 2 {
                    detailData[firstDay]![index].order -= 1
                }
                
                let totalSecond = tableView.numberOfRows(inSection: secondDay)
                detailData[secondDay]?.insert(data, at: totalSecond - 1)
                detailData[secondDay]?[totalSecond - 1].order = totalSecond - 1
                detailData[secondDay]?[totalSecond - 1].days = secondDay + 1
                detailData[secondDay]?[totalSecond].order = totalSecond
            }
            
            self.tableView.moveRow(at: firstIndexPath, to: indexPath)
 
            Path.initialIndexPath = indexPath
            
        default:
            
            guard Path.initialIndexPath != nil else { return }
            
            guard let cell = self.tableView.cellForRow(at: Path.initialIndexPath!) as? TripListTableViewCell else {
                return
            }
            
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: {
                Path.cellSnapShot?.center = cell.center
                Path.cellSnapShot?.transform = .identity
                Path.cellSnapShot?.alpha = 0.0
                cell.alpha = 1.0
                
            }, completion: { (finished) in
                if finished {
                    Path.initialIndexPath = nil
                    Path.cellSnapShot?.removeFromSuperview()
                    Path.cellSnapShot = nil
                    
                    self.updateAllData(daysKey: self.daysKey, total: self.totalDays, datas: self.detailData)
                }
            })
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        let cellSnapshot: UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        
        ////        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        ////        cellSnapshot.layer.shadowRadius = 5.0
        ////        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}

/// Firebase "order" start from 0 ..., "days" start from 1 ...

/// Refactor: seperate collection view/ mapview/ table view to different controller?
