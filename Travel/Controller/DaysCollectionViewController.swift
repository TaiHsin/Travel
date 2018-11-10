//
//  DaysCollectionViewController.swift
//  Travel
//
//  Created by TaiShin on 2018/10/31.
//  Copyright © 2018年 TaiHsinLee. All rights reserved.
//

import UIKit

protocol DayCollectionViewDelegate: AnyObject {
    
    func didSelectDay(_ day: Int)
}

class DaysCollectionViewController: UICollectionViewController {
    
    weak var delegate: DayCollectionViewDelegate?
    
    var dates = [Date]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var locationArray: [[THdata]] = []
    
    var day: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
//         self.clearsSelectionOnViewWillAppear = false
        
//        preSelectCollectionView()
    }

    func setupCollectionView() {
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.allowsSelection = true
        
        let identifier = String(describing: MenuBarCollectionViewCell.self)
        
        let xib = UINib(nibName: identifier, bundle: nil)
        
        collectionView.register(xib, forCellWithReuseIdentifier: identifier)
        
        let footerXib = UINib(nibName: String(describing: DayCollectionFooter.self), bundle: nil)
        
        collectionView.register(
            footerXib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: String(describing: DayCollectionFooter.self)
        )
    }
    
    func preSelectCollectionView() {

        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        guard let cell = collectionView.cellForItem(at: indexPath) as? MenuBarCollectionViewCell else { return }

        cell.dayLabel.text = Constants.allString
        cell.weekLabel.isHidden = true
        cell.selectedView.isHidden = false
    }
    
    // MARK: - Data Source
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
        
        return dates.count + 1
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: MenuBarCollectionViewCell.self),
            for: indexPath)
        
        guard let dayTitleCell = cell as? MenuBarCollectionViewCell,
            indexPath.row < dates.count + 1 else {
                
                return cell
        }
        
        if indexPath.item == 0 {
            
            dayTitleCell.dayLabel.text = Constants.allString
            dayTitleCell.weekLabel.isHidden = true
            
            return dayTitleCell
        } else {
            
            dayTitleCell.dayLabel.text = String(indexPath.item)
            dayTitleCell.convertWeek(date: dates[indexPath.item - 1])
            
            return dayTitleCell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
        ) -> CGFloat {
        
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        
        return CGSize(width: 40, height: 60)
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
        ) {
        
        day = indexPath.item
        
        delegate?.didSelectDay(day)
        
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
        guard indexPath.item != 0 else {
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? MenuBarCollectionViewCell else {
                
                return
            }
            
            cell.selectedView.isHidden = false
            
            return
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? MenuBarCollectionViewCell else { return }
        
        cell.selectedView.isHidden = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? MenuBarCollectionViewCell else { return }
        
        cell.selectedView.isHidden = true
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
        ) -> UICollectionReusableView {
        
        guard let footerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: String(describing: DayCollectionFooter.self),
            for: indexPath
            ) as? DayCollectionFooter else { return UICollectionReusableView() }
        
        footerView.plusButton.addTarget(self, action: #selector(editDaysCollection(sender: )), for: .touchUpInside)
        
        return footerView
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
        ) {
        
        guard let cell = cell as? MenuBarCollectionViewCell else { return }
        
        if cell.isSelected {
            
            cell.selectedView.isHidden = false
        } else {
            
            cell.selectedView.isHidden = true
        }
    }
    
    @objc func editDaysCollection(sender: UIButton) {
        
        let alertVC = UIAlertController.showActionSheet(
            
            defaultOptions: [Constants.addNewDay],
            
            defaultCompletion: { [weak self] _ in
                
//                self?.addNewDay()
            },
            
            destructiveOptions: [Constants.deleteDay],
            
            destructiveCompletion: { [weak self] (_) in
                
//                self?.deleteDay()
        })
        
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension DaysCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
        ) -> CGSize {
        
        return CGSize(width: 40, height: 60)
    }
}
