//
//  TripSelectionViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/29.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TripSelectionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var detailView: UIView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var ref: DatabaseReference!
    
    let tripsManager = TripsManager()
    
    let decoder = JSONDecoder()
    
    var location: Location?
    
    var trips: [Trips] = []
    
    var daysArray: [Int] = []
    
    var daysKey = ""
    
    var dayIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        setupTableView()
        setupCollectionView()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        saveButton.layer.cornerRadius = 8
    }
    
    @IBAction func savePlace(_ sender: Any) {
        
        guard let location = location else { return }
        checkLocationDays(daysKey: daysKey, index: dayIndex, location: location)
        
        self.view.removeFromSuperview()
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    func setupTableView() {
        
        let identifier  = String(describing: TripTableViewCell.self)
        
        let xib = UINib(nibName: identifier, bundle: nil)
        
        tableView.register(xib, forCellReuseIdentifier: identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupCollectionView() {
        
        #warning ("Refactor: use enum to replace String(describing: ViewController.self)")
        let identifier = String(describing: DayCollectionViewCell.self)
        
        let xib = UINib(nibName: identifier, bundle: nil)
        
        collectionView.register(xib, forCellWithReuseIdentifier: identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension TripSelectionViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
        
        return trips.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: TripTableViewCell.self),
            for: indexPath
            ) as? TripTableViewCell else {
                return UITableViewCell()
        }
        
        if cell.isSelected {
            
            cell.nameLabel.textColor = UIColor.white
            cell.cellView.backgroundColor = UIColor.darkGray
        } else {
            
            cell.nameLabel.textColor = UIColor.darkGray
            cell.cellView.backgroundColor = UIColor.white
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.nameLabel.text = trips[indexPath.row].name
        
        return cell
    }

}

extension TripSelectionViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
        ) -> CGFloat {
        
        return 50
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TripTableViewCell else { return }
        
        cell.nameLabel.textColor = UIColor.white
        cell.cellView.backgroundColor = UIColor.darkGray
        
        daysKey = trips[indexPath.row].daysKey
        
        let totatl = trips[indexPath.row].totalDays
        createDays(total: totatl)
    }
    
    func tableView(
        _ tableView: UITableView,
        didDeselectRowAt indexPath: IndexPath
        ) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TripTableViewCell else { return }
        
        cell.nameLabel.textColor = UIColor.darkGray
        cell.cellView.backgroundColor = UIColor.white
    }
}

extension TripSelectionViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
        
        guard daysArray.count != 0 else {
            return 0
        }
        
        return daysArray.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: DayCollectionViewCell.self),
            for: indexPath
            ) as? DayCollectionViewCell else {

                return UICollectionViewCell()
        }
        
        print("---------")
        print(cell.isSelected)
        if cell.isSelected {
            
            cell.numberLabel.textColor = UIColor.white
            cell.cellView.backgroundColor = UIColor.darkGray
        } else {
            
            cell.numberLabel.textColor = UIColor.darkGray
            cell.cellView.backgroundColor = UIColor.white
        }
        
        cell.numberLabel.text = String(describing: daysArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? DayCollectionViewCell else { return }
        
        print(cell.isSelected)
        cell.numberLabel.textColor = UIColor.white
        cell.cellView.backgroundColor = UIColor.darkGray
        
        dayIndex = indexPath.item + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? DayCollectionViewCell else { return }
        
        print(cell.isSelected)
        cell.numberLabel.textColor = UIColor.darkGray
        cell.cellView.backgroundColor = UIColor.white
    }
}

extension TripSelectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
        ) -> CGFloat {
        
        return 5
    }
}

extension TripSelectionViewController {
    
    func createDays(total days: Int) {
        
        daysArray.removeAll()
        
        for index in 1 ... days {
            daysArray.append(index)
        }
        
        collectionView.reloadData()
        return
    }
    
    func fetchData() {
        
        trips.removeAll()
        tripsManager.fetchTripsData(
            success: { (datas) in
                
                self.trips = datas
                self.tableView.reloadData()
            },
            failure: { (_) in
                // TODO
            }
        )
    }
    
    #warning ("better way?")
    
//    func addLocation(daysKey: String, index: Int, location: Location) {
//
//        guard daysKey != "", index != 0 else { return }
//
//        self.updataLocation(daysKey: daysKey, days: index, location: location)
    
//        ref.child("/tripDays/\(daysKey)")
//            .queryOrdered(byChild: "isEmpty").observeSingleEvent(of: .value, with: { (snapshot) in
//
//                guard let value = snapshot.value as? NSDictionary else { return }
//
//                if value["isEmpty"] != nil {
//
//                    self.updataLocation(daysKey: daysKey, days: index, location: location)
//                } else {
//
//                    self.checkLocationDays(daysKey: daysKey, index: index, location: location)
//                }
//            })
//    }
    
    func checkLocationDays(daysKey: String, index: Int, location: Location) {
        
        guard daysKey != "", index != 0 else { return }
        
        ref.child("/tripDays/\(daysKey)")
            .queryOrdered(byChild: "days")
            .queryEqual(toValue: index)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    self.updataLocation(daysKey: daysKey, days: index, location: location)
                    return
                }

                let order = value.count
                
                self.updataLocation(
                    daysKey: daysKey,
                    order: order,
                    days: index,
                    location: location
                )
            })
    }
    
    func updataLocation(daysKey: String, order: Int = 0, days: Int, location: Location) {
        
        // Update to Firebase (Need to separate or not?)
        
        guard let key = self.ref.child("tripDays").childByAutoId().key else { return }
        
        let post = ["addTime": location.addTime,
                    "address": location.address,
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "locationId": key,
                    "name": location.name,
                    "order": order,
                    "photo": location.photo,
                    "days": days
            ] as [String: Any]
        
        let postUpdate = ["/tripDays/\(daysKey)/\(key)": post]
        
        ref.updateChildValues(postUpdate)
        
        // Remove isEmpty data
//        ref.child("/tripDays/\(daysKey)/isEmpty/").removeValue()
        NotificationCenter.default.post(name: Notification.Name("triplist"), object: nil)
    }
}
