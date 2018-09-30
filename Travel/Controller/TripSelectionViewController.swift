//
//  TripSelectionViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/29.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class TripSelectionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var detailView: UIView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var days: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    var places: [String] = ["Place1", "Place2", "Place3", "Place4", "Place5", "Place6", "Place7", "Place8"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        saveButton.layer.cornerRadius = 5
    }
    
    @IBAction func savePlace(_ sender: Any) {
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
        
        return places.count
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
        cell.nameLabel.text = places[indexPath.row]
        
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
        didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TripTableViewCell else { return }
        
        cell.nameLabel.textColor = UIColor.white
        cell.cellView.backgroundColor = UIColor.darkGray

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
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
        
        return days.count
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
            cell.cellView.backgroundColor = UIColor.darkGray
        } else {
            
            cell.numberLabel.textColor = UIColor.darkGray
            cell.cellView.backgroundColor = UIColor.white
        }
        
        cell.numberLabel.text = days[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? DayCollectionViewCell else { return }
        
        cell.numberLabel.textColor = UIColor.white
        cell.cellView.backgroundColor = UIColor.darkGray

    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? DayCollectionViewCell else { return }
        
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
