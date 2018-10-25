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

private struct Const {
    /// Image height/width for Large NavBar state
    static let ImageSizeForLargeState: CGFloat = 170
    /// Margin from right anchor of safe area to right anchor of Image
    static let ImageRightMargin: CGFloat = 90
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
    static let ImageBottomMarginForLargeState: CGFloat = 12
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
    static let ImageBottomMarginForSmallState: CGFloat = 6
    /// Image height/width for Small NavBar state
    static let ImageSizeForSmallState: CGFloat = 100
    /// Height of NavBar for Small state. Usually it's just 44
    static let NavBarHeightSmallState: CGFloat = 44
    /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
    static let NavBarHeightLargeState: CGFloat = 96.5
}

class MyTripViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    let tripsManager = TripsManager()
    
    var trips: [Trips] = []
 
    let dateFormatter = DateFormatter()
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    private let imageView = UIImageView(image: UIImage(named: "icon_logo"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupUI()
        
        emptyLabel.isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.fetchDataFailed(noti: )),
            name: Notification.Name("failure"),
            object: nil
        )
        
        activityIndicatorView.type = NVActivityIndicatorType.circleStrokeSpin
        activityIndicatorView.color = #colorLiteral(red: 0.6078431373, green: 0.631372549, blue: 0.7098039216, alpha: 1)
    
        activityIndicatorView.startAnimating()
        
        setupCollectionView()
        fetchData()
//        setupNavigationImage()
        
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
        
        navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.431372549, green: 0.4588235294, blue: 0.5529411765, alpha: 1)
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.431372549, green: 0.4588235294, blue: 0.5529411765, alpha: 1)
        
//        navigationController?.navigationBar.subviews[4].isHidden = false
        
//        emptyLabel.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        NSLayoutConstraint.activate([
//            imageView.heightAnchor.constraint(equalToConstant: 0),
//            ])
//
//        navigationController?.navigationBar.willRemoveSubview(imageView)
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        
        title = ""
        
        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(imageView)
        imageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = #colorLiteral(red: 0.4392156863, green: 0.4588235294, blue: 0.5333333333, alpha: 1)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor, constant: 10),
            //            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
            //            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            imageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            //            imageView.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 0)
            ])
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
                
                self?.sortDataWithUpComimgDate()
                #warning ("better not to reload data (only add/ insert one)?")
                
                self?.collectionView.reloadData()
                
                if self?.trips.count == 0 {
                    
                    self?.emptyLabel.isHidden = false
                } else {
                    
                    self?.emptyLabel.isHidden = true
                }
                
                self?.activityIndicatorView.stopAnimating()
            },
            
            failure: { (error) in
                
                self.activityIndicatorView.stopAnimating()
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
        
        guard let myTripCell = cell as? MyTripsCell, indexPath.item < trips.count else { return cell }
        
        myTripCell.delegate = self
    
        myTripCell.tripImage.image = UIImage(named: trips[indexPath.item].placePic)
        
        myTripCell.tripTitle.text = trips[indexPath.item].place
        
        #warning ("Refactor out to stand alone manager")
        
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
        tripsManager.deleteMyTrip(tripID: tripID, daysKey: daysKey)
                
        collectionView.deleteItems(at: [indexPath])
    }
}
