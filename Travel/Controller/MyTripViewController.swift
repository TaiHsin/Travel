//
//  MyTripViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/24.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class MyTripViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    let firebaseManager = FirebaseManager()
    
    let tripsManager = TripsManager(firebaseManager: FirebaseManager())
    
    var trips: [Trips] = []
 
    let dateFormatter = DateFormatter()
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    private let imageView = UIImageView(image: UIImage(named: "icon_logo"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyLabel.isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.fetchDataFailed(noti: )),
            name: .failure,
            object: nil
        )
        
        activityIndicatorView.type = NVActivityIndicatorType.circleStrokeSpin
        
        activityIndicatorView.color = UIColor.cloudyBlue
        
        activityIndicatorView.startAnimating()
        
        setupCollectionView()
        
        fetchData()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.createNewTrip(noti: )),
            name: .myTrips,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationbarItem()
    }
    
    func setupNavigationbarItem() {
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor.battleshipGrey
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor.battleshipGrey
    }
    
    @objc func fetchDataFailed(noti: Notification) {
        
        activityIndicatorView.stopAnimating()
        
        emptyLabel.isHidden = false
    }
    
    @objc func createNewTrip(noti: Notification) {
        
        fetchData()
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

            detailController.trip.append(trips[indexPath.item])
            
        default:
            
            return super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Fetch data from Firebase
    
    func fetchData() {
        
        trips.removeAll()
    
        firebaseManager.fetchTripsData(
            success: { [weak self] (datas) in
                
                self?.trips = datas
                
                self?.sortDataWithUpComimgDate()
                
                self?.collectionView.reloadData()
                
                if self?.trips.count == 0 {
                    
                    self?.emptyLabel.isHidden = false
                } else {
                    
                    self?.emptyLabel.isHidden = true
                }
                
                self?.activityIndicatorView.stopAnimating()
            },
            
            failure: { [weak self] (error) in
                
                print(error.localizedDescription)
                
                self?.activityIndicatorView.stopAnimating()
        })
    }
    
    func sortDataWithUpComimgDate() {
        
        trips.sort(by: {$0.startDate < $1.startDate})
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
        
        guard let myTripCell = cell as? MyTripsCell,
            indexPath.item < trips.count else {
                return cell
        }
        
        myTripCell.delegate = self
        
        myTripCell.setup(viewModel:
            MyTripsCellViewModel(trip: trips[indexPath.item])
        )
        
        return myTripCell
    }
}

extension MyTripViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        
        let width = Int(collectionView.frame.width - 25) / 2
        
        let height = (width * 4) / 3
        
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
        
        Analytics.logEvent("view_item", parameters: nil)
        
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
        
        firebaseManager.deleteMyTrip(tripID: tripID, daysKey: daysKey)
                
        collectionView.deleteItems(at: [indexPath])
    }
}
