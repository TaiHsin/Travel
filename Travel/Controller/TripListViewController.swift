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
    
    let dateFormatter = DateFormatter()
    
    let tripsManager = TripsManager()
    
    let photoManager = PhotoManager()

    let decoder = JSONDecoder()
    
    var ref: DatabaseReference!
    
    // Refactor

    var detailData: [Int: [Location]] = [:]
    
    var photo: UIImage?
    
    var photosDict: [String: UIImage] = [:]

    var daysArray: [Int] = []
    
    var name = ""
    
//    var trip = [Trips]()

    var totalDays = 0
    
    var daysKey = ""
    
    var index = 0
    
    var dates = [Date]()
    
    var startDate = 0.0
    
    var endDate = 0.0
    
    var isMyTrips = true
    
    var id = ""
    
    let mapViewHeight: CGFloat = 230.0
    
    var mapViewTopConstraints: NSLayoutConstraint?
    
    var mapViewHeightConstraints: NSLayoutConstraint?
    
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
        
        setupMapView()
        
        automaticallyAdjustsScrollViewInsets = false
        
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
        navigationItem.title = name
        navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.431372549, green: 0.4588235294, blue: 0.5529411765, alpha: 1)
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.431372549, green: 0.4588235294, blue: 0.5529411765, alpha: 1)
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
        
        let headerXib = UINib(
            nibName: String(describing: TriplistHeader.self),
            bundle: nil
        )
        
        tableView.register(
            headerXib,
            forHeaderFooterViewReuseIdentifier: String(describing: TriplistHeader.self)
        )
        
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//
//        tableView.contentInset = UIEdgeInsets(top: mapViewHeight, left: 0.0, bottom: 0.0, right: 0.0)
//
//        tableView.contentOffset = CGPoint(x: 0, y: -mapViewHeight)
    }
    
    func setupCollectionView() {
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.allowsSelection = true
        
        let identifier = String(describing: MenuBarCollectionViewCell.self)
        
        let xib = UINib(nibName: identifier, bundle: nil)
        
        collectionView.register(xib, forCellWithReuseIdentifier: identifier)
        
        let footerXib = UINib(nibName: String(describing: DayCollectionFooter.self), bundle: nil)
        
        collectionView.register(
            footerXib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: String(describing: DayCollectionFooter.self)
        )
    }
    
    // MARK: - Google Map View
    
    func setupMapView() {
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        mapViewTopConstraints = mapView.topAnchor.constraint(equalTo: collectionView.bottomAnchor)
        
        mapViewTopConstraints?.isActive = true
        
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        mapViewHeightConstraints = mapView.heightAnchor.constraint(equalToConstant: mapViewHeight)
        
        mapViewHeightConstraints?.isActive = true
        
    }

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
            
            let markerImage = UIImage(named: "icon_location")
            let markerView = UIImageView(image: markerImage)
            markerView.tintColor = #colorLiteral(red: 0.431372549, green: 0.4588235294, blue: 0.5490196078, alpha: 1)
            marker.iconView = markerView
            marker.title = data.name
            marker.map = mapView
            
            // Fit all markers in map camera
            
            bounds = bounds.includingCoordinate(marker.position)
            let update = GMSCameraUpdate.fit(bounds)
            mapView.setMinZoom(5, maxZoom: 15)
            mapView.animate(with: update)
        }
    }
    
    func switchDetailVC(location: Location) {
 
        guard let detailViewController = UIStoryboard.searchStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)) as? DetailViewController else { return }
        
        detailViewController.location = location
        detailViewController.isMyTrip = isMyTrips
        
        tabBarController?.present(detailViewController, animated: true)
        
//        self.addChild(detailViewController)
//
//        detailViewController.view.frame = self.view.frame
//        self.view.addSubview(detailViewController.view)
//        detailViewController.didMove(toParent: self)
    }
    
    @objc func updateLocation(noti: Notification) {
        
        detailData.removeAll()
        
        tripsManager.fetchDayList(daysKey: daysKey) { (location) in
            
            self.sortLocations(locations: location, total: self.daysArray.count)
            self.getPhotos()
            self.tableView.reloadData()
        }
    }

    func createWeekDay(startDate: Double, totalDays: Int) {
        
        for index in 0 ... totalDays - 1 {
            
            var date = Date(timeIntervalSince1970: startDate)
            
            date = Calendar.current.date(byAdding: .day, value: index, to: date)!
            dates.append(date)
        }
    }

    func getPhotos() {
        
        detailData.forEach { (key, values) in
            
            for item in values {
                
                let placeID = item.photo
                
                photoManager.loadFirstPhotoForPlace(placeID: placeID, success: { (photo) in
                    
                    self.photosDict[placeID] = photo
                    self.tableView.reloadData()
                    
                    self.tableView.reloadData()
                    
                }, failure: { (error) in
                    
                    guard let image = UIImage(named: "picture_placeholder") else { return }
                    self.photosDict["Nophoto"] = image
                    
                    self.tableView.reloadData()
                    })
            }
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
//        print(daysArray)
        
        createWeekDay(startDate: startDate, totalDays: days)
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
        self.getPhotos()
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
 
        guard let tripData = detailData[section] else { return 1 }
        guard tripData.count != 0 else {
            return 1
        }
        return tripData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // possible nil??
        guard let datas = detailData[indexPath.section], datas.count != 0 else {
            
            /// Empty cell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: TripListTableViewCell.self),
                for: indexPath
            )
            guard let emptyCell = cell as? TripListTableViewCell else { return UITableViewCell() }

            emptyCell.isEmpty = true
            emptyCell.switchCellContent()
            emptyCell.selectionStyle = .none

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
        
        listCell.isEmpty = false
        listCell.switchCellContent()
        
        #warning ("Refactor: seems will delay, better way?")
        let placeID = datas[indexPath.row].photo
        listCell.listImage.image = photosDict[placeID]
        
        
//        photoManager.loadFirstPhotoForPlace(placeID: placeId, success: { (photo) in
//
//            listCell.listImage.image = photo
//        }, failure: { (error) in
//
//            // TODO:
//            })
        
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
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: String(describing: TriplistHeader.self)) as? TriplistHeader else { return UIView() }
        headerView.backgroundColor = UIColor.darkGray
        
        let date = dates[section]
        dateFormatter.dateFormat = "MMM dd YYYY / EEEE"
        let dateString = dateFormatter.string(from: date)

        headerView.dateTitleLabel.text = dateString
        headerView.dayLabel.text = String(describing: daysArray[section] + 1)
        
//        let view = UIView()
//        view.backgroundColor = UIColor.darkGray
//
//        let label = UILabel()
//        label.text = String(describing: daysArray[section] + 1)
//
//        label.frame = CGRect(x: 5, y: 2.5, width: 200, height: 30)
//        label.textColor = UIColor.white
//        view.addSubview(label)
        
        return headerView
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
        ) -> CGFloat {
        
        return 40
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.2
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return nil
//    }
    
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
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TripListTableViewCell else { return }
        
        guard cell.isEmpty != true else { return }
        
        if editingStyle == .delete {
                
                guard let locationArray = detailData[indexPath.section] else { return }
                let location = locationArray[indexPath.row]
                deletLocation(daysKey: daysKey, location: location)
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
        dayTitleCell.convertWeek(date: dates[indexPath.item])
        
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
        
        return CGSize(width: 40, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tableViewIndexPath = IndexPath(row: 0, section: indexPath.row)
        tableView.scrollToRow(at: tableViewIndexPath, at: .top, animated: true)

        guard let cell = collectionView.cellForItem(at: indexPath) as? MenuBarCollectionViewCell else { return }
        
        cell.selectedView.isHidden = false
        
        guard let locations = detailData[indexPath.row] else { return }
        
        showMarker(locations: locations)
        
        mapView.setMinZoom(5, maxZoom: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? MenuBarCollectionViewCell else { return }
        
        cell.selectedView.isHidden = true
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
        ) -> CGSize {
        
        return CGSize(width: 40, height: 60)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
        ) -> UICollectionReusableView {
        
        guard let footerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: String(describing: DayCollectionFooter.self),
            for: indexPath
            ) as? DayCollectionFooter else { return UICollectionReusableView() }
        
        footerView.plusButton.addTarget(self, action: #selector(editDaysCollection(sender: )), for: .touchUpInside)
    
        return footerView
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
        ) {
        
        guard let cell = cell as? MenuBarCollectionViewCell else { return }
        
        if cell.isSelected {
            
            cell.selectedView.isHidden = false
        } else {
            
            cell.selectedView.isHidden = true
        }
    }
    
    @objc func editDaysCollection(sender: UIButton) {
        
        let alertVC = AlertManager.shared.showActionSheet(
            
            defaultOptions: ["Add new day"],
            
            defaultCompletion: { [weak self] _ in
                
                self?.addNewDay()
            },
            
            destructiveOptions: ["Delete last day"],
            
            destructiveCompletion: { [weak self] (_) in
                
                self?.deleteDay()
        })
                
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func addNewDay() {
        
        let total = daysArray.count
        daysArray.append(total)
        let newTotal = total + 1
        
        let array = [Location]()
        detailData[total] = array
        
        guard let last = dates.last else { return }

        guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: last) else { return }
        dates.append(newDate)
        
        let newDateDouble = Double(newDate.timeIntervalSince1970)
        
        collectionView.reloadData()
        tableView.reloadData()
        
        endDate = newDateDouble
        
        updateMyTrips(total: newTotal, end: newDateDouble)
        NotificationCenter.default.post(name: Notification.Name("myTrips"), object: nil)
    }
    
    func deleteDay() {
        
        let total = daysArray.count
        let newTotal = total - 1
        daysArray.remove(at: total - 1)
        dates.remove(at: total - 1)
        
        detailData.removeValue(forKey: newTotal)
        
        guard let date = dates.last else { return }
    
        collectionView.reloadData()
        tableView.reloadData()
        
        endDate = Double(date.timeIntervalSince1970)
        updateMyTrips(total: newTotal, end: endDate)
        deleteDay(daysKey: daysKey, day: total)
        NotificationCenter.default.post(name: Notification.Name("myTrips"), object: nil)
    }
    
    func updateMyTrips(total: Int, end: Double) {
        
        ref.updateChildValues(["/myTrips/\(id)/totalDays/": total])
        ref.updateChildValues(["/myTrips/\(id)/endDate/": end])
    }
    
    // Firebase update
    
    func deleteDay(daysKey: String, day: Int) {
        
        ref.child("tripDays")
            .child(daysKey)
            .queryOrdered(byChild: "days")
            .queryEqual(toValue: day)
            .observeSingleEvent(of: .value) { (snapshot) in
                guard let value = snapshot.value as? NSDictionary else { return }
                guard let keys = value.allKeys as? [String] else { return }
                
                for key in keys {
                    self.ref.child("/tripDays/\(daysKey)/\(key)").removeValue()
                }
        }
    }
    
    func deletLocation(daysKey: String, location: Location) {

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
    
    func updateMyTrip(dayskey: String, trip: Trips) {
        
        let post = ["place": trip.place,
                    "startDate": trip.startDate,
                    "endDate": trip.endDate,
                    "totalDays": trip.totalDays,
                    "createdTime": trip.createdTime,
                    "id": trip.id,
                    "placePic": trip.placePic,
                    "daysKey": trip.daysKey
            ] as [String: Any]
        
        let postUpdate = ["/myTrips/\(trip.id)": post]
        ref.updateChildValues(postUpdate)
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

/// Firebase "order" start from 0 ..., "days" start from 1 ..., detail start from 0

/// Refactor: seperate collection view/ mapview/ table view to different controller?
