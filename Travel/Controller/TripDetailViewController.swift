//
//  TripDetailViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/25.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class TripDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: UIView!
    
    
    var photo: UIImage?
    var days: [String] = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6"]
    var dates: [String] = ["Nov. 20", "Nov. 21", "Nov. 22", "Nov. 23", "Nov. 24", "Nov. 25"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    func setupCollectionView() {
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        collectionView.showsHorizontalScrollIndicator = false
        
        let identifier = String(describing: MenuBarCollectionViewCell.self)
        
        let xib = UINib(nibName: identifier, bundle: nil)
        
        collectionView.register(xib, forCellWithReuseIdentifier: identifier)
    }
}

extension TripDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: MenuBarCollectionViewCell.self),
            for: indexPath)
        
        guard let dayTitleCell = cell as? MenuBarCollectionViewCell, indexPath.row < 6 else { return cell }
        
        dayTitleCell.dayLabel.text = days[indexPath.row]
        dayTitleCell.dateLabel.text = dates[indexPath.item]
        
        return dayTitleCell
    }
}

extension TripDetailViewController: UICollectionViewDelegate {
    
}
