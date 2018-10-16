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

class PreservedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addPlace: UIBarButtonItem!
    
    let photoManager = PhotoManager()
    
    var ref: DatabaseReference!
    
    var place: GMSPlace?
    
    var photo: UIImage?
    
    var photoArray: [UIImage] = []
    
    var locationArray: [Location] = []
    
    let decoder = JSONDecoder()
    
    let dispatchGroup = DispatchGroup()
    
    let isFavorite = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
//        dispatchGroup.enter()
        fetchData()
        
//        dispatchGroup.notify(queue: .main) {
//            self.setupTableView()
//            self.tableView.reloadData()
//        }
        setupTableView()
 
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePreserved(noti: )),
            name: Notification.Name("preserved"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.431372549, green: 0.4588235294, blue: 0.5529411765, alpha: 1)
    }
    
    @objc func updatePreserved(noti: Notification) {
        
        fetchData()
    }
    
    @IBAction func searchPlace(_ sender: Any) {
        
        guard let controller = UIStoryboard.searchStoryboard()
            .instantiateViewController(
                withIdentifier: String(describing: SearchViewController.self)
            ) as? SearchViewController else { return }
        
        self.show(controller, sender: nil)
    }
    
    func setupTableView() {
        
        let xib = UINib(
            nibName: String(describing: PreservedTableViewCell.self),
            bundle: nil
        )
        
        tableView.register(xib, forCellReuseIdentifier: String(describing: PreservedTableViewCell.self))
        
        tableView.delegate = self
        
        tableView.dataSource = self
    }
    
    func fetchData() {
        
        locationArray.removeAll()
        
        fetchPreservedData(
            success: { (location) in
                print(self.locationArray)
                self.locationArray = location
                
                // Sort array alphabetically
                self.locationArray.sort(by: {$0.name < $1.name})
                
                self.getPhotos()
        },
            failure: { (_) in
                //TODO
        }
        )
    }

    func getPhotos() {
        
        for location in locationArray {
            
            let placeID = location.photo
            
            #warning ("photoArray order is wrong")
            photoManager.loadFirstPhotoForPlace(placeID: placeID, success: { (photo) in
                
                self.photoArray.append(photo)
                
                self.tableView.reloadData()
                
            }) { (error) in
                
                guard let image = UIImage(named: "picture_placeholder02") else { return }
                
                self.photoArray.append(image)
            }
        }
//        tableView.reloadData()
    }
    
    func showDetailInfo(location: Location) {
        
        guard let detailViewController = UIStoryboard.searchStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)) as? DetailViewController else { return }
        
        detailViewController.location = location
        detailViewController.isFavorite = isFavorite
        
        self.addChild(detailViewController)
        
        detailViewController.view.frame = self.view.frame
        self.view.addSubview(detailViewController.view)
        detailViewController.didMove(toParent: self)
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
        
//        let placeId = locationArray[indexPath.row].photo
//
//        photoManager.loadFirstPhotoForPlace(placeID: placeId) { (photo) in
//            cell.photoImage.image = photo
//        }

        if photoArray.count == locationArray.count {
            cell.photoImage.image = photoArray[indexPath.row]
        }
        
        cell.placeName.text = locationArray[indexPath.row].name
        
//        cell.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
//        cell.setSelected(true, animated: true)
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
    
    #warning ("Refact to TripsManager")
    func fetchPreservedData(
        success: @escaping ([Location]) -> Void,
        failure: @escaping (TripsError) -> Void
        ) {
        
        var location: [Location] = []
        
        ref.child("favorite").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? NSDictionary else { return }
            
            for value in value.allValues {
                
                // Data convert: can be refact out independently
                guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else { return }
                
                do {
                    let data = try self.decoder.decode(Location.self, from: jsonData)
                    
                    location.append(data)
                
                } catch {
                    print(error)
                }
            }
            print(location)
            success(location)
        }
    }
    
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
