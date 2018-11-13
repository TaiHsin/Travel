//
//  PreservedViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/27.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import GooglePlaces
import FirebaseDatabase
import NVActivityIndicatorView
import KeychainAccess

class PreservedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addPlace: UIBarButtonItem!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    let keychain = Keychain(service: "com.TaiHsinLee.Travel")
    
    let photoManager = PhotoManager()
    
    var ref: DatabaseReference!
    
    var place: GMSPlace?
    
    var photo: UIImage?
    
    var photoArray: [UIImage] = []
    
    var photosDict: [String: UIImage] = [:]
    
    var locationArray: [Location] = []
    
    let tabIndex = 2
    
    let decoder = JSONDecoder()
    
    let dispatchGroup = DispatchGroup()
    
    let isFavorite = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.fetchFailed(noti: )),
            name: .noData,
            object: nil
        )
        
        activityIndicatorView.type = NVActivityIndicatorType.circleStrokeSpin
        
        activityIndicatorView.color = UIColor.cloudyBlue
        
        activityIndicatorView.startAnimating()
        
        ref = Database.database().reference()
    
        setupTableView()
        
        fetchData()
 
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePreserved(noti: )),
            name: .collections,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor.battleshipGrey
        
        emptyLabel.textColor = UIColor.cloudyBlue
        
        emptyLabel.isHidden = true
    }
    
    @objc func fetchFailed(noti: Notification) {
        
        activityIndicatorView.stopAnimating()
        
        emptyLabel.isHidden = false
    }
    
    @objc func updatePreserved(noti: Notification) {
        
        fetchData()
    }
    
    @IBAction func searchPlace(_ sender: Any) {
        
        guard let controller = UIStoryboard.searchStoryboard()
            .instantiateViewController(
                withIdentifier: String(describing: SearchViewController.self)
            ) as? SearchViewController else {
                
                return
        }
        
        controller.tabIndex = tabIndex
        
        self.show(controller, sender: nil)
    }
    
    func setupTableView() {
        
        let xib = UINib(
            nibName: String(describing: PreservedTableViewCell.self),
            bundle: nil
        )
        
        tableView.register(
            xib,
            forCellReuseIdentifier: String(describing: PreservedTableViewCell.self)
        )
        
        tableView.delegate = self
        
        tableView.dataSource = self
    }
    
    func fetchData() {
        
        locationArray.removeAll()
        
        fetchPreservedData(
            success: { [weak self] (location) in

                self?.locationArray = location
                
                // Sort array alphabetically
                
                self?.locationArray.sort(by: {$0.name < $1.name})
                
                self?.getPhotos()
                
                if self?.locationArray.count == 0 {
                    
                    self?.emptyLabel.isHidden = false
                } else {
                    
                    self?.emptyLabel.isHidden = true
                }
                
        },
            failure: { [weak self]  (_) in
                self?.activityIndicatorView.stopAnimating()
        }
        )
    }

    func getPhotos() {
        
        for location in locationArray {
            
            let placeID = location.photo
            
            #warning ("photoArray order is wrong")
            
            photoManager.loadFirstPhotoForPlace(placeID: placeID, success: { [weak self] (photo) in
                
                self?.photosDict[placeID] = photo
                
                self?.activityIndicatorView.stopAnimating()
                
                self?.tableView.reloadData()
                
            }) { [weak self]  (error) in
                
                guard let image = UIImage(named: "picture_placeholder02") else {
                    
                    return
                }
                
                self?.photosDict[Constants.noPhoto] = image
                
                self?.activityIndicatorView.stopAnimating()
                
                self?.tableView.reloadData()
            }
        }
    }
    
    func showDetailInfo(location: Location) {
        
        guard let detailViewController = UIStoryboard
            .searchStoryboard()
            .instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)
            ) as? DetailViewController else {
                
                return
        }
        
        detailViewController.location = location
        
        detailViewController.isFavorite = isFavorite
        
        tabBarController?.present(detailViewController, animated: true)
    }
}

extension PreservedViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
        
        return locationArray.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: PreservedTableViewCell.self),
            for: indexPath) as? PreservedTableViewCell else {

                return UITableViewCell()
        }
        
        let photoID = locationArray[indexPath.row].photo

        cell.photoImage.image = photosDict[photoID]
    
        cell.placeName.text = locationArray[indexPath.row].name

        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
        ) {
        
        if editingStyle == .delete {
            
            let location = locationArray[indexPath.row]
 
            deleteData(location: location)
            
            locationArray.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            
            // TODO
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
        ) -> CGFloat {
        
        return 100
    }
}

extension PreservedViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        
        let locationData = locationArray[indexPath.row]
       
        showDetailInfo(location: locationData)
    }
}

// MARK: - Firebase data
extension PreservedViewController {
    
    func fetchPreservedData(
        success: @escaping ([Location]) -> Void,
        failure: @escaping (Error) -> Void
        ) {
        
        var location: [Location] = []
        
        guard let uid = keychain["userId"] else {
            
            NotificationCenter.default.post(name: .noData, object: nil)
           
            return
        }
        
        ref.child("/favorite/\(uid)").observeSingleEvent(of: .value) { [weak self]  (snapshot) in
            
            guard let self = self else {
                
                return
            }
            
            guard let value = snapshot.value as? NSDictionary else {
                
                NotificationCenter.default.post(name: .noData, object: nil)
                
                return
            }
            
            for value in value.allValues {
                
                // Data convert: can be refact out independently
                
                guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else {
                    
                    return
                }
                
                do {
                    let data = try self.decoder.decode(Location.self, from: jsonData)
                    
                    location.append(data)
                
                } catch {
                    
                    failure(error)
                }
            }
    
            success(location)
        }
    }
    
    func deleteData(location: Location) {
        
        guard let uid = keychain["userId"] else { return }
        
        ref.child("/favorite/\(uid)")
            .queryOrdered(byChild: "locationId")
            .queryEqual(toValue: location.locationId)
            .observeSingleEvent(of: .value) { [weak self]  (snapshot) in
            
                guard let value = snapshot.value as? NSDictionary else {
                    
                    return
                }
            
                guard let key = value.allKeys.first as? String else {
                    
                    return
                }
                
                self?.ref.child("/favorite/\(uid)/\(key)").removeValue()
        }
    }
}
