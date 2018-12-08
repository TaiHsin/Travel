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
    
    @IBOutlet var selectionView: UIView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    let firebaseManager = FirebaseManager()
    
    let tripsManager = TripsManager()
    
    let decoder = JSONDecoder()
    
    var location: Location?
    
    var trips: [Trips] = []
    
    var daysArray: [Int] = []
    
    var daysKey = ""
    
    var dayIndex = 0
    
    var tabIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
        setupCollectionView()
        
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectionView.layer.cornerRadius = 8
        
        selectionView.layer.masksToBounds = true
    }
    
    @IBAction func savePlace(_ sender: Any) {
        
        if dayIndex != 0 {
            
            guard let location = location else {
                
                return
            }
            
            firebaseManager.checkLocationDays(daysKey: daysKey, index: dayIndex, location: location)
            
            if tabIndex == 1 {
                
                guard let tripsnavi = self.presentingViewController?.children[0]
                    as? TripNaviViewController else {
                    
                    return
                }
                
                tripsnavi.popViewController(animated: true)
            } else if tabIndex == 2 {
                
                guard let collectionsNavi = self.presentingViewController?.children[1]
                    as? TripNaviViewController else {
                    
                    return
                }
                
                collectionsNavi.popViewController(animated: true)
            }
            
            removeAnimate()
        } else {
            
            // TODO: Add notice to inform user to select day
        }
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.superview?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            self.view.superview?.alpha = 0.0

        }, completion: {(finished: Bool)  in
            
            if finished {
                
                self.dismiss(animated: false, completion: nil)
            }
        })
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
        
        // Refactor: use enum to replace String(describing: ViewController.self)
        
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
            
            cell.cellView.backgroundColor = UIColor.battleshipGrey
        } else {
            
            cell.nameLabel.textColor = UIColor.battleshipGrey
            
            cell.cellView.backgroundColor = UIColor.white
        }
        
        cell.selectionStyle = .none
        
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
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TripTableViewCell else {
            
            return
        }
        
        cell.nameLabel.textColor = UIColor.white
       
        cell.cellView.backgroundColor = UIColor.battleshipGrey
        
        daysKey = trips[indexPath.row].daysKey
        
        let totatl = trips[indexPath.row].totalDays
        
        createDays(total: totatl)
    }
    
    func tableView(
        _ tableView: UITableView,
        didDeselectRowAt indexPath: IndexPath
        ) {
        
        guard let cell = tableView.cellForRow(
            at: indexPath
            ) as? TripTableViewCell else {
            
            return
        }
        
        cell.nameLabel.textColor = UIColor.battleshipGrey
        
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

        if cell.isSelected {
            
            cell.numberLabel.textColor = UIColor.white
            
            cell.cellView.backgroundColor = UIColor.battleshipGrey
        } else {
            
            cell.numberLabel.textColor = UIColor.battleshipGrey
            
            cell.cellView.backgroundColor = UIColor.white
        }
        
        cell.numberLabel.text = String(describing: daysArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(
            at: indexPath
            ) as? DayCollectionViewCell else {
                
                return
        }
        
        print(cell.isSelected)
        
        cell.numberLabel.textColor = UIColor.white
        
        cell.cellView.backgroundColor = UIColor.battleshipGrey
        
        dayIndex = indexPath.item + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(
            at: indexPath
            ) as? DayCollectionViewCell else {
                
                return
        }
        
        cell.numberLabel.textColor = UIColor.battleshipGrey
        
        cell.cellView.backgroundColor = UIColor.white
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
        ) {
        
        guard let cell = cell as? DayCollectionViewCell else { return }
        
        if cell.isSelected {
            
            cell.numberLabel.textColor = UIColor.white
            
            cell.cellView.backgroundColor = UIColor.battleshipGrey
          
        } else {
            
            cell.numberLabel.textColor = UIColor.battleshipGrey
            
            cell.cellView.backgroundColor = UIColor.white
        }
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
        
        firebaseManager.fetchTripsData(
            
            success: { (datas) in
                
                self.trips = datas
                
                self.tableView.reloadData()
            },
            failure: { (_) in
                // TODO
            }
        )
    }
}
