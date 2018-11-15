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
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    let firebaseManager = FirebaseManager()

    let dateFormatter = DateFormatter()
    
    let tripsManager = TripsManager()
    
    let photoManager = PhotoManager()
    
    let decoder = JSONDecoder()
    
    var ref: DatabaseReference!
    
    var dataArray: [[THdata]] = []
    
    var locationArray: [[THdata]] = []
    
    var locations: [Location] = [] // For showing marker in MapView
    
    var photosDict: [String: UIImage] = [:]
    
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

        daysCollectionViewController.dates = dates
        
        setupDaysContainerView()
        
        setupMapContainerView()
        
        setupNavigationItems()
        
        tra_addContentController(mapViewController, to: mapContainerView)

        tra_addContentController(listTableViewController, to: mapContainerView)
        
        tra_addContentController(daysCollectionViewController, to: daysContainerView)
    
        mapViewController.delegate = self
        
        listTableViewController.delegate = self
        
        daysCollectionViewController.delegate = self
        
        fetchData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateLocation(noti: )),
            name: .triplist,
            object: nil
        )
    }

    private func buildFromStoryboard<T>(_ name: String) -> T {
        
        let storyboard = UIStoryboard(name: name, bundle: nil)
        
        let identifier = String(describing: T.self)
        
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: identifier
            ) as? T else {
            
            fatalError("Missing \(identifier) in Storyboard")
        }
        
        return viewController
    }
    
    private func setupDaysContainerView() {
        
        daysContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(daysContainerView)
        
        NSLayoutConstraint.activate([
            daysContainerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            daysContainerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            daysContainerView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 8.0
            ),
            daysContainerView.heightAnchor.constraint(
                equalToConstant: 60.0
            )
            ])
    }
    
    private func setupMapContainerView() {
        
        mapContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mapContainerView)
        
        NSLayoutConstraint.activate([
            mapContainerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            mapContainerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            mapContainerView.topAnchor.constraint(
                equalTo: daysContainerView.bottomAnchor
            ),
            mapContainerView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
            ])
    }
    
    func setupNavigationItems() {
        
        navigationItem.hidesBackButton = true
        
        navigationItem.title = trip[0].name
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor.battleshipGrey
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor.battleshipGrey
    }
    
    /// Refactor
    func fetchData() {
        
        firebaseManager.fetchDayList(daysKey: trip[0].daysKey) { [weak self] (location) in
            
            guard let self = self else {
                
                return
            }
            
            self.sortLocations(locations: location, total: self.dates.count)
            
            self.daysCollectionViewController.preSelectCollectionView()
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func searchLocation(_ sender: UIBarButtonItem) {
        
        addAttractionSheet()
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
    
    func sortLocationsForMarkers() {
        
        locations.removeAll()
        
        locationArray.forEach { [weak self] (value) in

            for location in value where location.type == .location {

                self?.locations.append(location.location)
            }
        }
    }
    
    // Pass data to listTableView
    
    func passDatatoListTableView() {
        
        listTableViewController.photosDict = photosDict
        
        listTableViewController.locationArray = locationArray
        
        listTableViewController.dates = dates
        
        listTableViewController.tableView.reloadData()
    }
    
    @objc func updateLocation(noti: Notification) {
        
        dataArray.removeAll()
        
        firebaseManager.fetchDayList(daysKey: trip[0].daysKey) { [weak self] (location) in
            
            guard let self = self else { return }
            
            self.sortLocations(locations: location, total: self.dates.count)
            
            self.filterDatalist(day: self.day)
            
            self.getPhotos()
            
            self.passDatatoListTableView()
            
            self.sortLocationsForMarkers()
            
            self.mapViewController.showMarkers(locations: self.locations)
        }
    }
    
    func createWeekDay(startDate: Double, totalDays: Int) {
        
        for index in 0 ... totalDays - 1 {
            
            var date = Date(timeIntervalSince1970: startDate)
            
            date = Calendar.current.date(byAdding: .day, value: index, to: date)!
            
            dates.append(date)
        }
    }
    
    // get all photos
    func getPhotos() {
        
        dataArray.forEach { [weak self] (locations) in
            
            for item in locations {
                
                let placeID = item.location.photo
                
                photoManager.loadFirstPhotoForPlace(placeID: placeID, success: { [weak self] (photo) in
                    
                    self?.photosDict[placeID] = photo
                    
                }, failure: { (error) in
                    
                    print(error.localizedDescription)
                    
                    guard let image = UIImage(named: Constants.picPlaceholder) else { return }
                    
                    self?.photosDict[Constants.noPhoto] = image
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
        
        // Append empty object if array is empty
        
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

    func switchDetailVC(location: Location) {
        
        guard let detailViewController = UIStoryboard
            .searchStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)
            ) as? DetailViewController else {
                
                return
        }
        
        detailViewController.location = location
        
        detailViewController.isMyTrip = isMyTrips
        
        detailViewController.tabIndex = tabIndex
        
        /// add transition effect
        tabBarController?.present(detailViewController, animated: true)
    }

    func showAlertAction(message: String) {
        
        let alertVC = UIAlertController.showAlert(
            title: Constants.oops,
            message: message,
            cancel: false
        )
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func addNewDay() {

        guard let last = dates.last else { return }
        
        guard let newDate = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: last
            ) else {
                
                return
        }
        
        dates.append(newDate)
        
        let total = dates.count
        
        let newDateDouble = Double(newDate.timeIntervalSince1970)
        
        trip[0].endDate = newDateDouble
        
        dataArray.append([])
        
        dataArray[total - 1].append(
            THdata(
                location: Location.emptyLocation(),
                type: .empty
            )
        )
        
        if self.day == 0 {
         
            locationArray.append([])
            
            locationArray[total - 1].append(
                THdata(
                    location: Location.emptyLocation(),
                    type: .empty
                )
            )
        }
        
        updateMyTrips(total: total, end: newDateDouble)

        listTableViewController.dates = dates
        
        listTableViewController.tableView.reloadData()
        
        daysCollectionViewController.dates = dates
        
        NotificationCenter.default.post(name: .myTrips, object: nil)
    }
    
    func deleteDay() {
        
        let daysKey = trip[0].daysKey
        
        let total = dates.count
        
        guard self.day != total else {
            
            showAlertAction(message: Constants.cannotDeleteCurrent)
            
            return
        }
        
        guard total > 1 else {
            
            showAlertAction(message: Constants.cannotDelete)
            
            return
        }
        
        dates.removeLast()
        
        dataArray.removeLast()
        
        guard let date = dates.last else { return }
        
        let newTotal = dates.count
        
        if self.day == 0 {
            
            locationArray.removeLast()
        }
        
        trip[0].endDate = Double(date.timeIntervalSince1970)
        
        let endDate = trip[0].endDate
        
        updateMyTrips(total: newTotal, end: endDate)
        
        deleteDay(daysKey: daysKey, day: total)
        
        listTableViewController.dates = dates
        
        listTableViewController.tableView.reloadData()
        
        daysCollectionViewController.dates = dates
        
        NotificationCenter.default.post(name: .myTrips, object: nil)
    }
    
    // MARK: - Firebase functions
    
    func deleteDay(daysKey: String, day: Int) {
        
        ref.child("tripDays")
            .child(daysKey)
            .queryOrdered(byChild: "days")
            .queryEqual(toValue: day)
            .observeSingleEvent(of: .value) { [weak self]  (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else { return }
                
                guard let keys = value.allKeys as? [String] else { return }
                
                for key in keys {
                    
                    self?.ref.child("/tripDays/\(daysKey)/\(key)").removeValue()
                }
        }
    }
    
    func deleteLocation(location: Location) {
        
        let daysKey = trip[0].daysKey
        
        ref.child("tripDays")
            .child(daysKey)
            .queryOrdered(byChild: "locationId")
            .queryEqual(toValue: location.locationId)
            .observeSingleEvent(of: .value) { [weak self]  (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else { return }
                
                guard let key = value.allKeys.first as? String else { return }
                
                self?.ref.child("/tripDays/\(daysKey)/\(key)").removeValue()
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
    
    func updateAllData() {
        
        let daysKey = trip[0].daysKey
        
        let totalDays = trip[0].totalDays
        
        for day in 0 ... totalDays - 1 {
            
            dataArray[day].forEach({ [weak self] (location) in
                
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
                    
                    self?.ref.updateChildValues(postUpdate)
                }
            })
        }
    }
}

// MARK: - List table view delegate

extension TripListViewController: ListTableViewDelegate {
    
    func didTableHide(_ listTableViewController: ListTableViewController, isHiding: Bool) {
        
        mapViewController.handleShowListButton(isHiding: false)
    }
    
    func didUpdateData(_ listTableViewController: ListTableViewController, locationArray: [[THdata]]) {
        
        self.locationArray = locationArray
        
        updateLocalData()
        
        updateAllData()
        
        listTableViewController.locationArray = locationArray
        
        sortLocationsForMarkers()
        
        mapViewController.showMarkers(locations: locations)
    }
    
    func didDeleteData(_ listTableViewController: ListTableViewController, locationArray: [[THdata]], location: Location) {
        
        self.locationArray = locationArray
        
        deleteLocation(location: location)
        
        updateLocalData()
        
        updateAllData()
        
        listTableViewController.locationArray = locationArray
        
        sortLocationsForMarkers()
        
        mapViewController.showMarkers(locations: locations)
    }
    
    func didShowDetail(_ listTableViewController: ListTableViewController, location: Location) {
        
        switchDetailVC(location: location)
    }
}

// MARK: - Map view delegate

extension TripListViewController: MapViewDelegate {
    
    func didShowListHit(for mapViewController: MapViewController) {
        
        listTableViewController.handleTableVIewList(isHidding: false)
    }
}

// MARK: - Day collection view delegate

extension TripListViewController: DayCollectionViewDelegate {
    
    func didSelectDay(_ dayCollectionViewController: DaysCollectionViewController, _ day: Int) {
        
        self.day = day
        
        filterDatalist(day: day)
        
        listTableViewController.locationArray = locationArray
        
        listTableViewController.getPhotos()
        
        listTableViewController.dates = dates
        
        listTableViewController.day = day
        
        listTableViewController.tableView.reloadData()
        
        sortLocationsForMarkers()
        
        mapViewController.showMarkers(locations: locations)
    }
    
    func didAddDay(_ dayCollectionViewController: DaysCollectionViewController) {
        
        addNewDay()
    }
    
    func didDeleteDay(_ dayCollectionViewController: DaysCollectionViewController) {
        
        deleteDay()
    }
}
