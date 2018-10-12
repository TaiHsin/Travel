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
    
    // Reuse photo randomly
    // wait to re construct (requset Google photo or fake photo on Firebase)
    /// Array -> randomElement
    let photoArray: [UIImage] = [#imageLiteral(resourceName: "Hallstatt"), #imageLiteral(resourceName: "sri_lanka"), #imageLiteral(resourceName: "paris"), #imageLiteral(resourceName: "iceland"), #imageLiteral(resourceName: "iceland"), #imageLiteral(resourceName: "Hallstatt"), #imageLiteral(resourceName: "sri_lanka"), #imageLiteral(resourceName: "paris"), #imageLiteral(resourceName: "iceland"), #imageLiteral(resourceName: "iceland")]
    
    let tripsManager = TripsManager()
    
    var trips: [Trips] = []
 
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        fetchData()
        
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
        
        let identifier = String(describing: MyTripsCollectionViewCell.self)
        
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
            let totalDays = trips[indexPath.row].totalDays
            let daysKey = trips[indexPath.row].daysKey
            let name = trips[indexPath.row].name
            let startDate = trips[indexPath.row].startDate
            let endDate = trips[indexPath.row].endDate
            let id = trips[indexPath.row].id
            
            detailController.id = id
            detailController.endDate = endDate
            detailController.startDate = startDate
            detailController.name = name
            detailController.totalDays = totalDays
            detailController.daysKey = daysKey
//            detailController.trip.append(trips[indexPath.row])
            
        default:
            return super.prepare(for: segue, sender: sender)
        }
    }
    
    // TODO: call firebase fetchdata function
    
    func fetchData() {
        
        trips.removeAll()
    
        #warning ("Refact with other fetch data function with general type")
        tripsManager.fetchTripsData(
            success: { [weak self] (datas) in
                
                self?.trips = datas
                print(datas.count)
                
                #warning ("better not to reload data?")
                
                self?.collectionView.reloadData()
            },
            failure: { _ in
                //TODO
        })
    }
    
    @objc func createNewTrip(noti: Notification) {
        
        fetchData()
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
            withReuseIdentifier: String(describing: MyTripsCollectionViewCell.self),
            for: indexPath
        )
        
        guard let myTripCell = cell as? MyTripsCollectionViewCell, indexPath.row < trips.count else { return cell }
        
        myTripCell.tripImage.image = photoArray[indexPath.row]
        
        myTripCell.tripTitle.text = trips[indexPath.row].place
    
        #warning ("Refactor out to stand alone manager")
        
        print(trips[indexPath.row].startDate)
        
        dateFormatter.dateFormat = "yyyy MM dd"
        let startDate = Date(timeIntervalSince1970: trips[indexPath.row].startDate)
        let endDate = Date(timeIntervalSince1970: trips[indexPath.row].endDate)

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
        
//        print(trips[indexPath.row].daysKey)
        
//        let daysKey = trips[indexPath.row].daysKey
        
        performSegue(
            withIdentifier: String(describing: TripListViewController.self),
            sender: indexPath
        )
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        //        guard let controller = UIStoryboard.mainStoryboard()
        //            .instantiateViewController(
        //                withIdentifier: String(describing: TripDetailViewController.self)
        //            ) as? TripDetailViewController else { return }
        //
        //        show(controller, sender: nil)
    }
}
