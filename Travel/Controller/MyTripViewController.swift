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
    
    let photoArray: [UIImage] = [#imageLiteral(resourceName: "paris"), #imageLiteral(resourceName: "Hallstatt"), #imageLiteral(resourceName: "sri_lanka"), #imageLiteral(resourceName: "iceland")]

    let titleArray: [String] = ["Paris", "Hallstatt", "Sri Lanka", "Iceland"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
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
}

extension MyTripViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyTripsCollectionViewCell.self), for: indexPath)
        
        guard let myTripCell = cell as? MyTripsCollectionViewCell, indexPath.row < 4 else { return cell }
        
        myTripCell.tripImage.image = photoArray[indexPath.row]
        
        myTripCell.tripTitle.text = titleArray[indexPath.row]
        
        return myTripCell
    }
}

extension MyTripViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = 145
        
        let height = 185
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
}
