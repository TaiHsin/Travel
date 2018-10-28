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

enum Modify {
    case add, delete
}

class TripListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var showListButton: UIButton!
    
    @IBOutlet weak var backView: UIView!
    
    var snapshot: UIView?
    
    var sourceIndexPath: IndexPath?
    
    private let locationManager = CLLocationManager()
    
    let contentOffsetView = UIView()
    
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
    
    var daysArray: [Int] = []
    
    var index = 0
    
    var dates = [Date]()
    
    var trip = [Trips]()

    var isMyTrips = true
    
    var isDaily = false
    
    var day = 0
    
    let tabIndex = 1
    
    let contentOffsetViewVisiblewHeight: CGFloat = 230.0
    
    var contentOffsetViewTopConstraints: NSLayoutConstraint?
    
    var contentOffsetViewViewHeightConstraints: NSLayoutConstraint?
    
    var backViewTopConstraints: NSLayoutConstraint?
    
    var backViewHeightConstraints: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        createDays(total: trip[0].totalDays)
        
        fetchData()
        
        setupLocationManager()
    
        setupBackgroundView()
        
        setupContentOffsetView()

        mapView.delegate = self
        
        let padding = showListButton.frame.height
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: padding, right: 0)
        
        setupCollectionView()
        
        setupTableView()
        
        automaticallyAdjustsScrollViewInsets = false
        
        setupLongPressGesture()
        
        setupTapGesture()
        
        showListButton.isHidden = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateLocation(noti: )),
            name: .triplist,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationItems()
        
        /// Navigation large title effect
//        navigationController?.navigationBar.prefersLargeTitles = false
        
//        guard let navigationBar = navigationController?.navigationBar else { return }
        //        let view = navigationBar.subviews[0]
        //        let count = navigationBar.subviews.count
//        navigationBar.subviews[4].isHidden = true
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
            
            self.sortLocations(locations: location, total: self.daysArray.count - 1)
            self.filterDatalist(day: self.day)
            self.getPhotos()
            self.tableView.reloadData()
            
            self.preSelectCollectionView()
        }
    }
    
    func preSelectCollectionView() {
        
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        guard let cell = collectionView.cellForItem(at: indexPath) as? MenuBarCollectionViewCell else { return }
        
        cell.dayLabel.text = Constants.allString
        cell.weekLabel.isHidden = true
        cell.selectedView.isHidden = false
        
        day = 0
        filterDatalist(day: day)
        
        var allLocations: [Location] = []
        
        locationArray.forEach { (value) in
            
            for location in value where location.type != .empty {
                
                allLocations.append(location.location)
            }
        }
        
        showMarker(locations: allLocations)
        mapView.setMinZoom(5, maxZoom: 30)
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func showTriplist(_ sender: UIButton) {
        
        tableView.isHidden = false
        contentOffsetView.isHidden = false
        showListButton.isHidden = true
        backView.isHidden = false
    }
    
    /// Maybe combine with showlist?
    
    func hideTriplist() {
        
        tableView.isHidden = true
        contentOffsetView.isHidden = true
        showListButton.isHidden = false
        backView.isHidden = true
    }
    
    func setupTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tapGestureRecognized(gestureRecognizer: ))
        )
        
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        contentOffsetView.addGestureRecognizer(tapGesture)
        
        tableView.isUserInteractionEnabled = true
    }

    func setupLongPressGesture() {
        
        // setup long press gesture
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPressGestureRecognized(longPress: ))
        )
        self.tableView.addGestureRecognizer(longPress)
    }
    
    @objc func tapGestureRecognized(gestureRecognizer: UITapGestureRecognizer) {
        
        hideTriplist()
    }
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        
//        locationManager.requestWhenInUseAuthorization()
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
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.contentInset = UIEdgeInsets(
            top: contentOffsetViewVisiblewHeight,
            left: 0.0,
            bottom: 0.0,
            right: 0.0
        )
        
        tableView.contentOffset = CGPoint(x: 0, y: -contentOffsetViewVisiblewHeight)
        
        self.mapView.bringSubviewToFront(tableView)
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
    
    func setupContentOffsetView() {
        
        contentOffsetView.backgroundColor = .clear
        
        contentOffsetView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(contentOffsetView)
        
        contentOffsetViewTopConstraints = contentOffsetView
            .topAnchor
            .constraint(
                equalTo: collectionView.bottomAnchor
        )
        
        contentOffsetViewTopConstraints?.isActive = true
        
        contentOffsetView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        contentOffsetView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        contentOffsetViewViewHeightConstraints = contentOffsetView
            .heightAnchor
            .constraint(
                equalToConstant: contentOffsetViewVisiblewHeight
        )
        
        contentOffsetViewViewHeightConstraints?.isActive = true
    }
    
    func setupBackgroundView() {
        
        mapView.bringSubviewToFront(backView)
        
        backView.translatesAutoresizingMaskIntoConstraints = false
        
        let mapViewHeight = mapView.frame.height
        
        backViewTopConstraints = backView
            .topAnchor
            .constraint(
                equalTo: tableView.topAnchor,
                constant: contentOffsetViewVisiblewHeight
        )
        
        backViewTopConstraints?.isActive = true
        
        backViewHeightConstraints = backView
            .heightAnchor
            .constraint(
                equalToConstant: mapViewHeight - contentOffsetViewVisiblewHeight
        )
        
        backViewHeightConstraints?.isActive = true
    }
    
    // Locate device location and show location button
    func getCurrentLocation() {
        locationManager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        
        //        mapView.settings.myLocationButton = true
    }
    
    func showMarker(locations: [Location]) {
        
        var bounds = GMSCoordinateBounds()
        
        for data in locations {
            
            let latitude = data.latitude
            let longitude = data.longitude
            
            let position = CLLocationCoordinate2DMake(latitude, longitude)
            let marker = GMSMarker(position: position)
            
            let markerImage = UIImage(named: Constants.locationIcon)
            let markerView = UIImageView(image: markerImage)
            markerView.tintColor = UIColor.cloudyBlue
            marker.iconView = markerView
            marker.title = data.name
            marker.map = mapView
            
            mapView.setMinZoom(5, maxZoom: 15)
            
            let bottomHeight = mapView.frame.size.height - 260
            let edgeInsets = UIEdgeInsets(top: 80, left: 50, bottom: bottomHeight, right: 50)
            bounds = bounds.includingCoordinate(marker.position)
            mapView.animate(with: .fit(bounds, with: edgeInsets))
            
            //            mapView.animate(with: .fit(bounds, withPadding: 50.0))
        }
    }
    
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
            
            self.sortLocations(locations: location, total: self.daysArray.count - 1)
            
            self.filterDatalist(day: self.day)
            self.getPhotos()
            self.tableView.reloadData()
        }
    }
    
    // create days array depend on passed days
    func createDays(total days: Int) {
        
        for index in 0 ... days {
            daysArray.append(index)
        }
        
        createWeekDay(startDate: trip[0].startDate, totalDays: days)
        
        return
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
                    self.tableView.reloadData()
                    
                }, failure: { (error) in
                    
                    guard let image = UIImage(named: Constants.picPlaceholder) else { return }
                    self.photosDict[Constants.noPhoto] = image
                    
                    self.tableView.reloadData()
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
    
    #warning ("Refact to alert manager")
    
    func showAlertWith() {
        
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: Constants.cancelString, style: .cancel) { (_) in
            
        }
        
        let favoriteAction = UIAlertAction(title: Constants.addFromCollections, style: .default) { (_) in
            
            let tabController = self.view.window?.rootViewController as? UITabBarController
            tabController?.dismiss(animated: false, completion: nil)
            tabController?.selectedIndex = 1
        }
        
        let searchAction = UIAlertAction(title: Constants.searchPlace, style: .default) { (_) in
            
            guard let controller = UIStoryboard.searchStoryboard()
                .instantiateViewController(
                    withIdentifier: String(describing: SearchViewController.self)
                ) as? SearchViewController else {
                    
                    return
            }
            
            controller.tabIndex = self.tabIndex
            
            self.show(controller, sender: nil)
        }
        
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(favoriteAction)
        actionSheetController.addAction(searchAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func changeContentOffsetViewTopConstraint(contentOffset: CGPoint) {
        
        contentOffsetViewTopConstraints?.isActive = false
        contentOffsetViewViewHeightConstraints?.isActive = false
        
        contentOffsetViewTopConstraints = contentOffsetView
            .topAnchor
            .constraint(
            equalTo: collectionView.bottomAnchor,
            constant: -(contentOffset.y - (-contentOffsetViewVisiblewHeight))
        )
        
        contentOffsetViewViewHeightConstraints = contentOffsetView
            .heightAnchor
            .constraint(
                equalToConstant: contentOffsetViewVisiblewHeight
        )
        
        contentOffsetViewTopConstraints?.isActive = true
        contentOffsetViewViewHeightConstraints?.isActive = true
        
        view.layoutIfNeeded()
    }
    
    func changeBackViewTopConstraint(contentOffset: CGPoint) {
        
        backViewTopConstraints?.isActive = false
        backViewHeightConstraints?.isActive = false
        
        backViewTopConstraints = backView
            .topAnchor
            .constraint(
                equalTo: tableView.topAnchor,
                constant: -contentOffset.y
        )
        
        backViewHeightConstraints = backView
            .heightAnchor
            .constraint(
                equalToConstant: tableView.frame.height
        )
        
        backViewTopConstraints?.isActive = true
        backViewHeightConstraints?.isActive = true
        
        view.layoutIfNeeded()
    }
    
    func changeContentOffsetViewHeightConstraint(contentOffset: CGPoint) {
        
        contentOffsetViewTopConstraints?.isActive = false
        contentOffsetViewViewHeightConstraints?.isActive = false
        
        contentOffsetViewTopConstraints = contentOffsetView
            .topAnchor
            .constraint(equalTo: collectionView.bottomAnchor)
        
        contentOffsetViewViewHeightConstraints = contentOffsetView
            .heightAnchor
            .constraint(equalToConstant: -contentOffset.y)
        
        contentOffsetViewTopConstraints?.isActive = true
        contentOffsetViewViewHeightConstraints?.isActive = true
        
        view.layoutIfNeeded()
    }
    
    func changeBackViewHeightConstraint(contentOffset: CGPoint) {
        
        backViewTopConstraints?.isActive = false
        backViewHeightConstraints?.isActive = false
        
        backViewTopConstraints = backView
            .topAnchor
            .constraint(equalTo: tableView.topAnchor, constant: -contentOffset.y)
        
        backViewHeightConstraints = backView
            .heightAnchor
            .constraint(equalToConstant: tableView.frame.height)
        
        backViewTopConstraints?.isActive = true
        backViewHeightConstraints?.isActive = true
        
        view.layoutIfNeeded()
    }
}

// MARK: - CLLocationManagerDelegate

extension TripListViewController: CLLocationManagerDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView == tableView else { return }
        if scrollView.contentOffset.y > -contentOffsetViewVisiblewHeight && scrollView.contentOffset.y < 20 {
            
            changeContentOffsetViewHeightConstraint(contentOffset: scrollView.contentOffset)
            changeBackViewHeightConstraint(contentOffset: scrollView.contentOffset)
            
        } else if  scrollView.contentOffset.y <= -contentOffsetViewVisiblewHeight {
            
            changeContentOffsetViewTopConstraint(contentOffset: scrollView.contentOffset)
            changeBackViewTopConstraint(contentOffset: scrollView.contentOffset)
            
            if scrollView.contentOffset.y < -(contentOffsetViewVisiblewHeight * 1.4) {
                
                hideTriplist()
            }
        }
    }
    
    // didChangeAuthorization function is called when the user grants or revokes location permissions.
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse else { return }
        
        getCurrentLocation()
    }
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
        
        return locationArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let tripData = locationArray[section]
        
        return tripData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        switch locationArray[indexPath.section][indexPath.row].type {
            
        case .empty:
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: TripListTableViewCell.self),
                for: indexPath
            )
            
            guard let emptyCell = cell as? TripListTableViewCell else { return UITableViewCell() }
            
            emptyCell.isEmpty = true
            emptyCell.switchCellContent()
            emptyCell.selectionStyle = .none
            
            return emptyCell
            
        case .location:
            
            let datas = locationArray[indexPath.section]
            
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
            
            let placeID = datas[indexPath.row].location.photo
            listCell.listImage.image = photosDict[placeID]
            
            listCell.placeNameLabel.text = datas[indexPath.row].location.name
            listCell.addressLabel.text = datas[indexPath.row].location.address
            
            listCell.selectionStyle = .none
            return listCell
        }
    }
}

// MARK: - Table View Delegate

extension TripListViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
        ) -> UIView? {
        
        if day == 0 {
            
            guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: String(describing: TriplistHeader.self)) as? TriplistHeader else { return UIView() }
            headerView.backgroundColor = UIColor.darkGray
            
            let date = dates[section]
            dateFormatter.dateFormat = Constants.completeDate
            let dateString = dateFormatter.string(from: date)
            
            headerView.dateTitleLabel.text = dateString
            headerView.dayLabel.text = String(describing: daysArray[section] + 1)
            
            return headerView
        } else {
            
            guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: String(describing: TriplistHeader.self)) as? TriplistHeader else { return UIView() }
            headerView.backgroundColor = UIColor.darkGray
            
            let date = dates[day - 1]
            dateFormatter.dateFormat = Constants.completeDate
            let dateString = dateFormatter.string(from: date)
            
            headerView.dateTitleLabel.text = dateString
            headerView.dayLabel.text = String(describing: day)
            
            return headerView
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
        ) -> CGFloat {
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.1
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        
        let datas = locationArray[indexPath.section]
        let location = datas[indexPath.row]
        
        guard location.type == .location else { return }
        
        switchDetailVC(location: location.location)
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
        ) -> UITableViewCell.EditingStyle {
        
        let type = locationArray[indexPath.section][indexPath.row].type
        
        guard type == .location else {
            
            return UITableViewCell.EditingStyle.none
        }
    
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
        ) {
        
        let daysKey = trip[0].daysKey
        
        if editingStyle == .delete {
            
            guard day == 0 else {
                
                let location = locationArray[indexPath.section][indexPath.row].location
                let updateIndexPath = IndexPath(row: indexPath.row, section: day - 1)
                
                deletLocation(daysKey: daysKey, location: location)
                
                changeOrder(daysKey: daysKey, indexPath: updateIndexPath, location: location, type: .delete)
                
                locationArray[indexPath.section].remove(at: indexPath.row)
                dataArray[day - 1].remove(at: indexPath.row)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                if locationArray[indexPath.section].count == 0 {
                    
                    locationArray[indexPath.section].append(THdata(location: Location.emptyLocation(), type: .empty))
                    dataArray[day - 1].append(THdata(location: Location.emptyLocation(), type: .empty))
                    
                    let newIndexPath = IndexPath(row: 0, section: indexPath.section)
                    tableView.insertRows(at: [newIndexPath], with: .none)
                }
                
                return
            }
            
            let datas = locationArray[indexPath.section]
            let location = datas[indexPath.row]
            
            deletLocation(daysKey: daysKey, location: location.location)
            
            changeOrder(daysKey: daysKey, indexPath: indexPath, location: location.location, type: .delete)
            
            locationArray[indexPath.section].remove(at: indexPath.row)
            dataArray[indexPath.section].remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if locationArray[indexPath.section].count == 0 {
                
                locationArray[indexPath.section].append(THdata(location: Location.emptyLocation(), type: .empty))
                dataArray[indexPath.section].append(THdata(location: Location.emptyLocation(), type: .empty))
                
                let newIndexPath = IndexPath(row: 0, section: indexPath.section)
                tableView.insertRows(at: [newIndexPath], with: .none)
            }
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
        
        if indexPath.item == 0 {
            
            dayTitleCell.dayLabel.text = Constants.allString
            dayTitleCell.weekLabel.isHidden = true
            
            return dayTitleCell
        }
        
        dayTitleCell.dayLabel.text = String(daysArray[indexPath.item])
        dayTitleCell.convertWeek(date: dates[indexPath.item - 1])
        
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
        ) {
        
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
        guard indexPath.item != 0 else {
            
            day = indexPath.item
            
            filterDatalist(day: day)
            tableView.reloadData()
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? MenuBarCollectionViewCell else {
                
                return
            }
            
            cell.selectedView.isHidden = false
            
            var allLocations: [Location] = []
            
            locationArray.forEach { (value) in
                
                for location in value where location.type == .location {
                    
                        allLocations.append(location.location)
                }
            }
            
            showMarker(locations: allLocations)
            mapView.setMinZoom(5, maxZoom: 30)
            
            return
        }
        
        day = indexPath.item
        
        filterDatalist(day: day)
        tableView.reloadData()
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? MenuBarCollectionViewCell else { return }
        
        cell.selectedView.isHidden = false
        
        guard locationArray[0].count != 0 else {
            
            mapView.clear()
            mapView.animate(toZoom: 10)
            return
        }
    
        var allLocations: [Location] = []
        
        locationArray[0].forEach { (value) in
            
            if value.type != .empty {
                allLocations.append(value.location)
            }
        }
        
        mapView.clear()
        showMarker(locations: allLocations)
        mapView.setMinZoom(1, maxZoom: 30)
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
    
    func showAlertAction() {
        
        let alertVC = AlertManager.shared.showAlert(
            with: [Constants.oops],
            message: Constants.cannotDelete,
            cancel: false,
            completion: {
                // TODO
        })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func editDaysCollection(sender: UIButton) {
        
        let alertVC = AlertManager.shared.showActionSheet(
            
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
        
        let total = daysArray.count
        daysArray.append(total)
        let newTotal = total
        
        guard let last = dates.last else { return }
        
        guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: last) else { return }
        dates.append(newDate)
        
        let newDateDouble = Double(newDate.timeIntervalSince1970)
        
        trip[0].endDate = newDateDouble
//        endDate = newDateDouble
        
        dataArray.append([])
        dataArray[newTotal - 1].append(THdata(location: Location.emptyLocation(), type: .empty))
        
        if self.day == 0 {
         
            locationArray.append([])
            locationArray[newTotal - 1].append(THdata(location: Location.emptyLocation(), type: .empty))
        }
        
        collectionView.reloadData()
        tableView.reloadData()
        
        updateMyTrips(total: newTotal, end: newDateDouble)
        NotificationCenter.default.post(name: .myTrips, object: nil)
    }
    
    func deleteDay() {
        
        let daysKey = trip[0].daysKey
        
        let total = dates.count
        
        guard total > 1 else {
            
            showAlertAction()
            
            return
        }
        
        daysArray.removeLast()
        dates.removeLast()
        dataArray.removeLast()
        
        guard let date = dates.last else { return }
        let newTotal = dates.count
        
        if self.day == 0 {
            
            locationArray.removeLast()
        }
        
        collectionView.reloadData()
        tableView.reloadData()
        
        trip[0].endDate = Double(date.timeIntervalSince1970)
        let endDate = trip[0].endDate
        
        updateMyTrips(total: newTotal, end: endDate)
        deleteDay(daysKey: daysKey, day: total)
        NotificationCenter.default.post(name: .myTrips, object: nil)
    }
    
    // MARK: - Firebase functions
    
    func updateMyTrips(total: Int, end: Double) {
        
        let id = trip[0].id
        
        ref.updateChildValues(["/myTrips/\(id)/totalDays/": total])
        ref.updateChildValues(["/myTrips/\(id)/endDate/": end])
    }
    
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
        
        let daysKey = trip[0].daysKey
        let days = indexPath.section + 1
        let order = indexPath.row
        
        let orderUpdate = ["/tripDays/\(daysKey)/\(location.locationId)/order": order]
        self.ref.updateChildValues(orderUpdate)
        
        let daysUpdate = ["/tripDays/\(daysKey)/\(location.locationId)/days": days]
        self.ref.updateChildValues(daysUpdate)
    }
    
        func changeOrder(daysKey: String, indexPath: IndexPath, location: Location, type: Modify) {
    
            let locationArray = dataArray[indexPath.section]
    
            // Compare other data order to update
            for item in locationArray {
    
                switch type {
    
                case .delete:
                    if item.location.order >= indexPath.row, item.location.locationId != location.locationId {
    
                        let newOrder = item.location.order - 1
                        let key = item.location.locationId
                        let postUpdate = ["/tripDays/\(daysKey)/\(key)/order": newOrder]
                        ref.updateChildValues(postUpdate)
                    }
    
                /// not use??
                case .add:
                    if item.location.order >= indexPath.row, item.location.locationId != location.locationId {
    
                    let newOrder = item.location.order + 1
                    let key = item.location.locationId
                    let postUpdate = ["/tripDays/\(daysKey)/\(key)/order": newOrder]
                    ref.updateChildValues(postUpdate)
                    }
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

// MARK: - Long press gesture to swap table view cell

extension TripListViewController {
    
    @objc func longPressGestureRecognized(longPress: UILongPressGestureRecognizer) {
        
        let daysKey = trip[0].daysKey
        
        let totalDays = trip[0].totalDays
        
        let state = longPress.state

        let location = longPress.location(in: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: location) else {

            let numbers = locationArray[0].count
            
            for number in 0 ..< numbers where locationArray[0][number].type == .empty {

                    locationArray[0].remove(at: number)
                    let indexPath = IndexPath(row: number, section: 0)

                    tableView.deleteRows(at: [indexPath], with: .none)
            }

            cleanUp()
            
            return
        }
        
        switch state {
            
        case .began:
            
            guard locationArray[indexPath.section][indexPath.row].type == .location else {
                return }
            
            sourceIndexPath = indexPath
            guard let cell = self.tableView.cellForRow(at: indexPath) as? TripListTableViewCell else {
                return }
            
            snapshot = customSnapshotFromView(inputView: cell)
            
            guard let snapshot = self.snapshot else {
                return }
            
            var center = cell.center
            snapshot.center = center
            snapshot.alpha = 0.0
            self.tableView.addSubview(snapshot)
            
            // Insert empty cell for one row's section
            
            if self.locationArray[indexPath.section].count == 1 {
                
                self.locationArray[indexPath.section].append(THdata(location: Location.emptyLocation(), type: .empty))
                let indexPath = IndexPath(row: 1, section: indexPath.section)
                self.tableView.insertRows(at: [indexPath], with: .none)
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                center.y = location.y
                snapshot.center = center
                snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                snapshot.alpha = 0.98
                cell.alpha = 0.0
                
            }, completion: { (finished) in
                if finished {
                 
                    cell.isHidden = true
                }
            })
            
        case .changed:
            
            guard let snapshot = snapshot else {
                return }
            
            var center = snapshot.center
            center.y = location.y
            snapshot.center = center
            
            guard let sourceIndexPath = self.sourceIndexPath else {
                return
            }
            
            if indexPath != sourceIndexPath {
                
                let firstDay = sourceIndexPath.section
                let secondDay = indexPath.section
                
                let dataToMove = locationArray[firstDay][sourceIndexPath.row]
                locationArray[firstDay].remove(at: sourceIndexPath.row)
                locationArray[secondDay].insert(dataToMove, at: indexPath.row)
                
                tableView.moveRow(at: sourceIndexPath, to: indexPath)
                self.sourceIndexPath = indexPath
            }
            
        default:

            guard let sourceIndexPath = self.sourceIndexPath else {
                return
            }
            
            var sourceIndex = sourceIndexPath
            
            /// Check empty cell in section and remove it
            
            let numbers = locationArray[indexPath.section].count
            
            for number in 0 ..< numbers {
                
                if locationArray[indexPath.section][number].type == .empty {
                    
                    locationArray[indexPath.section].remove(at: number)
                    let indexPath = IndexPath(row: number, section: indexPath.section)
                    
                    tableView.deleteRows(at: [indexPath], with: .none)
                    
                    let newIndexPath = IndexPath(row: 0, section: indexPath.section)
                    sourceIndex = newIndexPath
                    
                    break
                }
            }
            
            guard let cell = self.tableView.cellForRow(at: sourceIndex) as? TripListTableViewCell else {
                
                cleanUp()
                return
            }
            
            guard let snapshot = self.snapshot else {
                return
            }
            
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: {
                snapshot.center = cell.center
                snapshot.transform = .identity
                snapshot.alpha = 0.0
                cell.alpha = 1.0
                
            }, completion: { (finished) in
                if finished {
                 
                    self.cleanUp()
                    
                    /// Update all data with current day(section) and order(row)
                    self.updateLocalData()
                    
                    self.updateAllData(daysKey: daysKey, total: totalDays)
                }
            })
        }
    }
    
    func cleanUp() {

        sourceIndexPath = nil
        snapshot?.removeFromSuperview()
        snapshot = nil
        tableView.reloadData()
    }
    
    func customSnapshotFromView(inputView: UIView) -> UIView? {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        
        if let currentContext = UIGraphicsGetCurrentContext() {
            inputView.layer.render(in: currentContext)
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        UIGraphicsEndImageContext()
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        
        //        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        //        cellSnapshot.layer.shadowRadius = 5.0
        //        cellSnapshot.layer.shadowOpacity = 0.4
        return snapshot
    }
}

/// Firebase "order" start from 0 ..., "days" start from 1 ..., dataArray start from 0

/// Refactor: seperate collection view/ mapview/ table view to different controller?
