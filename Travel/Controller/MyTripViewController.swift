//
//  MyTripViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/24.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class MyTripViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    
    // Reuse photo randomly
    // wait to re construct (requset Google photo or fake photo on Firebase)
    
    /// Array -> randomElement
    let photoArray: [UIImage] = [#imageLiteral(resourceName: "Hallstatt"), #imageLiteral(resourceName: "sri_lanka"), #imageLiteral(resourceName: "iceland"), #imageLiteral(resourceName: "notre_dame_de_paris"), #imageLiteral(resourceName: "palais_du_louvre")]
    
    let tripsManager = TripsManager()
    
//    var tripsPhoto: [UIImage] = []
    
    var trips: [Trips] = []
 
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        fetchData()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        #warning ("Refactor: use enum for all notification strings")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.createNewTrip(noti: )),
            name: Notification.Name("myTrips"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupCollectionView() {
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        let identifier = String(describing: MyTripsCell.self)
        
        let xib = UINib(nibName: identifier, bundle: nil)
        
        collectionView.register(xib, forCellWithReuseIdentifier: identifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case String(describing: TripListViewController.self):
            
            guard let detailController = segue.destination as? TripListViewController,
            
                let indexPath = sender as? IndexPath else {
                    
                    return
            }
            let totalDays = trips[indexPath.item].totalDays
            let daysKey = trips[indexPath.item].daysKey
            let name = trips[indexPath.item].name
            let startDate = trips[indexPath.item].startDate
            let endDate = trips[indexPath.item].endDate
            let id = trips[indexPath.item].id
            
            detailController.id = id
            detailController.endDate = endDate
            detailController.startDate = startDate
            detailController.name = name
            detailController.totalDays = totalDays
            detailController.daysKey = daysKey
//            detailController.trip.append(trips[indexPath.item])
            
        default:
            return super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Fetch data from Firebase
    
    func fetchData() {
        
        trips.removeAll()
    
        #warning ("Refact with other fetch data function with general type")
        tripsManager.fetchTripsData(
            success: { [weak self] (datas) in
                
                self?.trips = datas
                print(datas.count)
                
                #warning ("better not to reload data (only add/ insert one)?")
                
                self?.collectionView.reloadData()
            },
            failure: { _ in
                //TODO
        })
    }

    @objc func createNewTrip(noti: Notification) {
        
        fetchData()
    }

    // MARK: - Delete Items
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        addBarButtonItem.isEnabled = !editing
        
        guard let indexPaths = collectionView?.indexPathsForVisibleItems else { return }
        
        for indexPath in indexPaths {
            
            guard let cell = collectionView?.cellForItem(at: indexPath) as? MyTripsCell else { return }
            
            // use "isEditing" didSet to hide/ show UI
            
            cell.isEditing = editing
        }
    }
}

extension MyTripViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
        
        return trips.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: MyTripsCell.self),
            for: indexPath
        )
        
        guard let myTripCell = cell as? MyTripsCell, indexPath.item < trips.count else { return cell }
        
        myTripCell.delegate = self
    
        myTripCell.tripImage.image = photoArray.randomElement()
        
        myTripCell.tripTitle.text = trips[indexPath.item].place
        
        #warning ("Refactor out to stand alone manager")
        
        print(trips[indexPath.item].startDate)
        
        dateFormatter.dateFormat = "yyyy MM dd"
        let startDate = Date(timeIntervalSince1970: trips[indexPath.item].startDate)
        let endDate = Date(timeIntervalSince1970: trips[indexPath.item].endDate)

        dateFormatter.dateFormat = "yyyy"
        let startYear = dateFormatter.string(from: startDate)
        let endYear = dateFormatter.string(from: endDate)

        if startYear == endYear {
            myTripCell.yearsLabel.text = startYear
        } else {
            myTripCell.yearsLabel.text = startYear + " - " + endYear
        }

        dateFormatter.dateFormat = "MMM.dd"
        let startMonth = dateFormatter.string(from: startDate)
        let endMonth = dateFormatter.string(from: endDate)

        myTripCell.dateLabel.text = startMonth + " - " + endMonth
        
        return myTripCell
    }
}

extension MyTripViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        
        let width = 145
        
        let height = 185
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
        ) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
        ) -> CGFloat {
        
        return 15
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
        ) -> CGFloat {
        
        return 15
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        
        performSegue(
            withIdentifier: String(describing: TripListViewController.self),
            sender: indexPath
        )
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - MyTripCell Delegate

extension MyTripViewController: MyTripCellDelegate {
    
    func delete(for cell: MyTripsCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let daysKey = trips[indexPath.item].daysKey
        let tripID = trips[indexPath.item].id
        trips.remove(at: indexPath.item)
        tripsManager.deleteMyTrip(tripID: tripID, daysKey: daysKey)
                
        collectionView.deleteItems(at: [indexPath])
    }
}
