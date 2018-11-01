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

class TripListViewController: UIViewController {
    
    fileprivate lazy var mapViewController: MapViewController = self.buildFromStoryboard("MyTrip")

    fileprivate lazy var listTableViewController: ListTableViewController = self.buildFromStoryboard("MyTrip")
    
    fileprivate lazy var daysCollectionViewController: DaysCollectionViewController = self.buildFromStoryboard("MyTrip")
    
    private let daysContainerView = UIView()
    
    private let mapContainerView = UIView()
    
    /////////
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    let firebaseManager = FirebaseManager()

    let dateFormatter = DateFormatter()
    
    let tripsManager = TripsManager()
    
    let photoManager = PhotoManager()
    
    let decoder = JSONDecoder()
    
    var ref: DatabaseReference!
    
    // Refactor
    
    var dataArray: [[THdata]] = []
    
    var locationArray: [[THdata]] = []
    
    var locations: [Location] = []
    
    var photo: UIImage?
    
    var photosDict: [String: UIImage] = [:]
    
    var index = 0
    
    var dates = [Date]()
    
    var trip = [Trips]()

    var isMyTrips = true
    
    var isDaily = false
    
    var day = 0
    
    let tabIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        createWeekDay(startDate: trip[0].startDate, totalDays: trip[0].totalDays)

        fetchData()
        
        setupDaysContainerView()
        setupMapContainerView()
        
        addContentController(daysCollectionViewController, to: daysContainerView)
        addContentController(mapViewController, to: mapContainerView)
        addContentController(listTableViewController, to: mapContainerView)
        
        daysCollectionViewController.dates = dates
        
//        setupBackgroundView()
//
//        setupContentOffsetView()
//
//        setupMapView()
//
//        setupCollectionView()
//
//        setupTableView()
//
//        automaticallyAdjustsScrollViewInsets = false
//
//        setupGestures()
//
//        showListButton.isHidden = true
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.updateLocation(noti: )),
//            name: .triplist,
//            object: nil
//        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationItems()
    }
    
    private func buildFromStoryboard<T>(_ name: String) -> T {
        
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let identifier = String(describing: T.self)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            
            fatalError("Missing \(identifier) in Storyboard")
        }
        return viewController
    }
    
    private func setupDaysContainerView() {
        
        daysContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(daysContainerView)
        
        NSLayoutConstraint.activate([
            daysContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            daysContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            daysContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0),
            daysContainerView.heightAnchor.constraint(equalToConstant: 60.0)
            ])
    }
    
    private func setupMapContainerView() {
        
        mapContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapContainerView)
        
        NSLayoutConstraint.activate([
            mapContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapContainerView.topAnchor.constraint(equalTo: daysContainerView.bottomAnchor),
            mapContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    private func addContentController(_ child: UIViewController, to containerView: UIView) {
        
        addChild(child)
        containerView.addSubview(child.view)
        child.view.frame = containerView.frame
        child.didMove(toParent: self)
    }
    
    private func removeContentController(_ child: UIViewController, from containerView: UIView) {
        
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    func setupNavigationItems() {
        
        /// what's diff with leftItemsSupplementBackButton?
        navigationItem.hidesBackButton = true
        navigationItem.title = trip[0].name
        navigationItem.leftBarButtonItem?.tintColor = UIColor.battleshipGrey
        navigationItem.rightBarButtonItem?.tintColor = UIColor.battleshipGrey
    }
    
    func fetchData() {
        tripsManager.fetchDayList(daysKey: trip[0].daysKey) { (location) in
            
            self.sortLocations(locations: location, total: self.dates.count)
            self.filterDatalist(day: self.day)
            self.getPhotos()
            
            self.listTableViewController.dates = self.dates
            self.listTableViewController.photosDict = self.photosDict
            self.listTableViewController.locationArray = self.locationArray
        }
    }
    
//    func preSelectCollectionView() {
//
//        let indexPath = IndexPath(row: 0, section: 0)
//        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
//        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
//        guard let cell = collectionView.cellForItem(at: indexPath) as? MenuBarCollectionViewCell else { return }
//
//        cell.dayLabel.text = Constants.allString
//        cell.weekLabel.isHidden = true
//        cell.selectedView.isHidden = false
//
//        day = 0
//        filterDatalist(day: day)
//
//        var allLocations: [Location] = []
//
//        locationArray.forEach { (value) in
//
//            for location in value where location.type != .empty {
//
//                allLocations.append(location.location)
//            }
//        }
    
//        showMarker(locations: allLocations)
//        mapView.setMinZoom(5, maxZoom: 30)
//    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
//    func setupTapGesture() {
//
//        let tapGesture = UITapGestureRecognizer(
//            target: self,
//            action: #selector(self.tapGestureRecognized(gestureRecognizer: ))
//        )
//
//        tapGesture.numberOfTapsRequired = 1
//        tapGesture.numberOfTouchesRequired = 1
////        contentOffsetView.addGestureRecognizer(tapGesture)
//
////        tableView.isUserInteractionEnabled = true
//    }

//    func setupLongPressGesture() {
//
//        let longPress = UILongPressGestureRecognizer(
//            target: self,
//            action: #selector(longPressGestureRecognized(longPress: ))
//        )
//        self.tableView.addGestureRecognizer(longPress)
//    }
    
    @IBAction func searchLocation(_ sender: UIBarButtonItem) {
        
        addAttractionSheet()
    }
    
//    func setupContentOffsetView() {
//
//        contentOffsetView.backgroundColor = .clear
//
//        contentOffsetView.translatesAutoresizingMaskIntoConstraints = false
//
//        view.addSubview(contentOffsetView)
//
//        contentOffsetViewTopConstraints = contentOffsetView
//            .topAnchor
//            .constraint(
//                equalTo: collectionView.bottomAnchor
//        )
//
//        contentOffsetViewTopConstraints?.isActive = true
//
//        contentOffsetView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//
//        contentOffsetView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//
//        contentOffsetViewViewHeightConstraints = contentOffsetView
//            .heightAnchor
//            .constraint(
//                equalToConstant: contentOffsetViewVisiblewHeight
//        )
//
//        contentOffsetViewViewHeightConstraints?.isActive = true
//    }
//
//    func setupBackgroundView() {
//
////        mapView.bringSubviewToFront(backView)
//
//        backView.translatesAutoresizingMaskIntoConstraints = false
//
////        let mapViewHeight = mapView.frame.height
//
//        backViewTopConstraints = backView
//            .topAnchor
//            .constraint(
//                equalTo: tableView.topAnchor,
//                constant: contentOffsetViewVisiblewHeight
//        )
//
//        backViewTopConstraints?.isActive = true
//
////        backViewHeightConstraints = backView
////            .heightAnchor
////            .constraint(
////                equalToConstant: mapViewHeight - contentOffsetViewVisiblewHeight
////        )
//
//        backViewHeightConstraints?.isActive = true
//    }
    
    func switchDetailVC(location: Location) {
        
        guard let detailViewController = UIStoryboard.searchStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)) as? DetailViewController else { return }
        
        detailViewController.location = location
        detailViewController.isMyTrip = isMyTrips
        detailViewController.tabIndex = tabIndex
        
        tabBarController?.present(detailViewController, animated: true)
    }
    
    func filterDatalist(day: Int) {
        
        locationArray.removeAll()
        
        guard day != 0 else {
            
            locationArray = dataArray
            
            return
        }
        
        let data = dataArray[day - 1]
        locationArray.append(data)
    }
    
    @objc func updateLocation(noti: Notification) {
        
        dataArray.removeAll()
        
        tripsManager.fetchDayList(daysKey: trip[0].daysKey) { (location) in
            
            self.sortLocations(locations: location, total: self.dates.count)
            
            self.filterDatalist(day: self.day)
            self.getPhotos()
//            self.tableView.reloadData()
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
        
        dataArray.forEach { (locations) in
            
            for item in locations {
                
                let placeID = item.location.photo
                
                photoManager.loadFirstPhotoForPlace(placeID: placeID, success: { (photo) in
                    
                    self.photosDict[placeID] = photo
//                    self.tableView.reloadData()
                    
                }, failure: { (error) in
                    
                    print(error.localizedDescription)
                    
                    guard let image = UIImage(named: Constants.picPlaceholder) else { return }
                    self.photosDict[Constants.noPhoto] = image
                    
//                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // Get data and sort locally
    func sortLocations(locations: [THdata], total: Int) {
        
        // better way to avoid for loops?
        for _ in 0 ... total - 1 {
            dataArray.append([])
        }
        
        for index in 0 ..< locations.count {
            
            for key in 0 ... total - 1 where locations[index].location.days == key + 1 {
                
                let item = locations[index]
                dataArray[key].append(item)
            }
        }
        
        for number in 0 ... total - 1 {
            
            dataArray[number].sort(by: {$0.location.order < $1.location.order})
        }
        
        /// Append empty object if array is empty
        for index in 0 ..< dataArray.count where dataArray[index].count == 0 {
            
            dataArray[index].append(THdata(location: Location.emptyLocation(), type: .empty))
        }
    }
    
    func addAttractionSheet() {
        
        let alertVC = UIAlertController.showActionSheet(
            
            defaultOptions: [Constants.addFromCollections, Constants.searchPlace],
            
            defaultCompletion: { [weak self] action in
                
                switch action.title {
                    
                case Constants.addFromCollections:
                    
                    let tabController = self?.view.window?.rootViewController as? UITabBarController
                    tabController?.dismiss(animated: false, completion: nil)
                    tabController?.selectedIndex = 1
                    
                case Constants.searchPlace:
                    
                    guard let controller = UIStoryboard.searchStoryboard()
                        .instantiateViewController(
                            withIdentifier: String(describing: SearchViewController.self)
                        ) as? SearchViewController else {
                            
                            return
                    }
                    
                    controller.tabIndex = self!.tabIndex
                    
                    self?.show(controller, sender: nil)
                    
                default:
                    
                    break
                }
            })
        
        self.present(alertVC, animated: true, completion: nil)
    }
}
 
// MARK: - Collection View Delegate Flow Layout

extension TripListViewController {

    
    func showAlertAction() {
        
        let alertVC = UIAlertController.showAlert(
            title: Constants.oops,
            message: Constants.cannotDelete,
            cancel: false
        )
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func editDaysCollection(sender: UIButton) {
        
        let alertVC = UIAlertController.showActionSheet(
            
            defaultOptions: [Constants.addNewDay],
            
            defaultCompletion: { [weak self] _ in
                
                self?.addNewDay()
            },
            
            destructiveOptions: [Constants.deleteDay],
        
            destructiveCompletion: { [weak self] (_) in
                
                self?.deleteDay()
        })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func addNewDay() {

        guard let last = dates.last else { return }
        
        guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: last) else { return }
        dates.append(newDate)
        let total = dates.count
        
        let newDateDouble = Double(newDate.timeIntervalSince1970)
        
        trip[0].endDate = newDateDouble
        
        dataArray.append([])
        dataArray[total - 1].append(THdata(location: Location.emptyLocation(), type: .empty))
        
        if self.day == 0 {
         
            locationArray.append([])
            locationArray[total - 1].append(THdata(location: Location.emptyLocation(), type: .empty))
        }
        
//        collectionView.reloadData()
//        tableView.reloadData()
        
        updateMyTrips(total: total, end: newDateDouble)
        NotificationCenter.default.post(name: .myTrips, object: nil)
    }
    
    func deleteDay() {
        
        let daysKey = trip[0].daysKey
        
        let total = dates.count
        
        guard total > 1 else {
            
            showAlertAction()
            
            return
        }
        
        dates.removeLast()
        dataArray.removeLast()
        
        guard let date = dates.last else { return }
        let newTotal = dates.count
        dataArray.removeLast()
        
        if self.day == 0 {
            
            locationArray.removeLast()
        }
//
//        collectionView.reloadData()
//        tableView.reloadData()
        
        trip[0].endDate = Double(date.timeIntervalSince1970)
        let endDate = trip[0].endDate
        
        updateMyTrips(total: newTotal, end: endDate)
        deleteDay(daysKey: daysKey, day: total)
        NotificationCenter.default.post(name: .myTrips, object: nil)
    }
    
    // MARK: - Firebase functions
    
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
    
    func deleteLocation(daysKey: String, location: Location) {
        
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
    
    func updateMyTrips(total: Int, end: Double) {
        
        let id = trip[0].id
        
        ref.updateChildValues(["/myTrips/\(id)/totalDays/": total])
        ref.updateChildValues(["/myTrips/\(id)/endDate/": end])
    }
    
    func updateData(daysKey: String, indexPath: IndexPath, location: Location) {
        
        let daysKey = trip[0].daysKey
        let days = indexPath.section + 1
        let order = indexPath.row
        
        let orderUpdate = ["/tripDays/\(daysKey)/\(location.locationId)/order": order]
        self.ref.updateChildValues(orderUpdate)
        
        let daysUpdate = ["/tripDays/\(daysKey)/\(location.locationId)/days": days]
        self.ref.updateChildValues(daysUpdate)
    }
    
    func changeOrder(daysKey: String, indexPath: IndexPath, location: Location) {
        
        let locationArray = dataArray[indexPath.section]
        
        // Compare other data order to update
        for item in locationArray {

                if item.location.order >= indexPath.row, item.location.locationId != location.locationId {
                    
                    let newOrder = item.location.order - 1
                    let key = item.location.locationId
                    let postUpdate = ["/tripDays/\(daysKey)/\(key)/order": newOrder]
                    ref.updateChildValues(postUpdate)
                }
        }
    }
    
    func updateLocalData() {
        
        let sections = locationArray.count
        
        switch sections {
            
        case 1:
        
            let rows = locationArray[0].count
            
            for row in 0 ..< rows {
                
                locationArray[0][row].location.days = day
                locationArray[0][row].location.order = row
            }
            dataArray[day - 1] = locationArray[0]
            
        default:
            
            for section in 0 ..< sections {
                
                let rows = locationArray[section].count
                
                for row in 0 ..< rows {
                    
                    locationArray[section][row].location.days = section + 1
                    locationArray[section][row].location.order = row
                }
            }
            dataArray = locationArray
        }
    }
    
    func updateAllData(daysKey: String, total: Int) {
        
        let daysKey = trip[0].daysKey
        
        for day in 0 ... total - 1 {
            
            dataArray[day].forEach({ (location) in
                
                let key = location.location.locationId
                
                if key != Constants.emptyString {
                    
                    let post = ["addTime": location.location.addTime,
                                "address": location.location.address,
                                "latitude": location.location.latitude,
                                "longitude": location.location.longitude,
                                "locationId": key,
                                "name": location.location.name,
                                "order": location.location.order,
                                "photo": location.location.photo,
                                "days": location.location.days,
                                "position": location.location.position
                        ] as [String: Any]
                    
                    let postUpdate = ["/tripDays/\(daysKey)/\(key)": post]
                    self.ref.updateChildValues(postUpdate)
                }
                })
        }
    }
}

extension TripListViewController: ListHideDelegate {
    
    func didTableHide(isHiding: Bool) {
        mapViewController.showListButton.isHidden = !isHiding
    }
}

/// Firebase "order" start from 0 ..., "days" start from 1 ..., dataArray start from 0

/// Refactor: seperate collection view/ mapview/ table view to different controller?
