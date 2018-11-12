//
//  ListTableViewController.swift
//  Travel
//
//  Created by TaiShin on 2018/10/31.
//  Copyright © 2018年 TaiHsinLee. All rights reserved.
//

import UIKit

protocol ListTableViewDelegate: AnyObject {
    
    func didTableHide(isHiding: Bool)
    
    func didUpdateData(locationArray: [[THdata]])
    
    func didDeleteData(locationArray: [[THdata]], location: Location)
    
    func didShowDetail(location: Location)
}

class ListTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let backView = UIView()
    
    let contentOffsetView = UIView()
    
    let dateFormatter = DateFormatter()
    
    let contentOffsetViewVisiblewHeight: CGFloat = 230.0
    
    var contentOffsetViewTopConstraints: NSLayoutConstraint?
    
    var contentOffsetViewViewHeightConstraints: NSLayoutConstraint?
    
    var backViewTopConstraints: NSLayoutConstraint?
    
    var backViewHeightConstraints: NSLayoutConstraint?
    
    var locationArray: [[THdata]] = [] 
    
    var photosDict: [String: UIImage] = [:]
    
    var dates: [Date] = []
    
    var trip: [Trips] = []
    
    var day = 0

    var snapshot: UIView?

    var sourceIndexPath: IndexPath?
    
    weak var delegate: ListTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        setupContentOffsetView()
        setupBackgroundView()
        setupTableView()
        setupGestures()
    }

    func setupTableView() {
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        /// Use extension and string array to do register
        
        let xib = UINib(
            nibName: String(describing: TripListTableViewCell.self),
            bundle: nil
        )
        
        tableView.register(
            xib,
            forCellReuseIdentifier: String(describing: TripListTableViewCell.self)
        )
        
        let headerXib = UINib(
            nibName: String(describing: TriplistHeader.self),
            bundle: nil
        )
        
        tableView.register(
            headerXib,
            forHeaderFooterViewReuseIdentifier: String(describing: TriplistHeader.self)
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.contentInset = UIEdgeInsets(
            top: contentOffsetViewVisiblewHeight,
            left: 0.0,
            bottom: 0.0,
            right: 0.0
        )
        
        tableView.contentOffset = CGPoint(x: 0, y: -contentOffsetViewVisiblewHeight)
    }
    
    func setupGestures() {
        
        setupTapGesture()
        setupLongPressGesture()
    }

    func setupContentOffsetView() {

        contentOffsetView.backgroundColor = .clear

        contentOffsetView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentOffsetView)

        contentOffsetViewTopConstraints = contentOffsetView
            .topAnchor
            .constraint(
                equalTo: view.topAnchor
        )

        contentOffsetViewTopConstraints?.isActive = true

        contentOffsetView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

        contentOffsetView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        contentOffsetViewViewHeightConstraints = contentOffsetView
            .heightAnchor
            .constraint(
                equalToConstant: contentOffsetViewVisiblewHeight
        )

        contentOffsetViewViewHeightConstraints?.isActive = true
    }

    func setupBackgroundView() {
        
        backView.backgroundColor = .white

        backView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backView)

//        let viewHeight = view.frame.height

        backViewTopConstraints = backView
            .topAnchor
            .constraint(
                equalTo: view.topAnchor,
                constant: contentOffsetViewVisiblewHeight
        )

        backViewTopConstraints?.isActive = true

        backView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        backView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        backView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
//        backViewHeightConstraints = backView
//            .heightAnchor
//            .constraint(
//                equalToConstant: viewHeight - contentOffsetViewVisiblewHeight
//        )
//
//        backViewHeightConstraints?.isActive = true
        
        view.sendSubviewToBack(backView)
    }

    func setupTapGesture() {

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tapGestureRecognized(gestureRecognizer: ))
        )

        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        contentOffsetView.addGestureRecognizer(tapGesture)

        tableView.isUserInteractionEnabled = true
    }

    func setupLongPressGesture() {

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPressGestureRecognized(longPress: ))
        )
        self.tableView.addGestureRecognizer(longPress)
    }

    @objc func tapGestureRecognized(gestureRecognizer: UITapGestureRecognizer) {

        handleTableVIewList(isHidding: true)
    }
    
    func handleTableVIewList(isHidding: Bool) {
        
        delegate?.didTableHide(isHiding: true)
        self.view.isHidden = isHidding
    }

    func changeContentOffsetViewTopConstraint(contentOffset: CGPoint) {

        contentOffsetViewTopConstraints?.isActive = false
        contentOffsetViewViewHeightConstraints?.isActive = false

        contentOffsetViewTopConstraints = contentOffsetView
            .topAnchor
            .constraint(
            equalTo: view.topAnchor,
            constant: -(contentOffset.y - (-contentOffsetViewVisiblewHeight))
        )

        contentOffsetViewViewHeightConstraints = contentOffsetView
            .heightAnchor
            .constraint(
                equalToConstant: contentOffsetViewVisiblewHeight
        )

        contentOffsetViewTopConstraints?.isActive = true
        contentOffsetViewViewHeightConstraints?.isActive = true

        view.layoutIfNeeded()
    }

    func changeBackViewTopConstraint(contentOffset: CGPoint) {

        backViewTopConstraints?.isActive = false
        backViewHeightConstraints?.isActive = false

        backViewTopConstraints = backView
            .topAnchor
            .constraint(
                equalTo: view.topAnchor,
                constant: -contentOffset.y
        )

        backViewHeightConstraints = backView
            .heightAnchor
            .constraint(
                equalToConstant: tableView.frame.height
        )

        backViewTopConstraints?.isActive = true
        backViewHeightConstraints?.isActive = true

        view.layoutIfNeeded()
    }

    func changeContentOffsetViewHeightConstraint(contentOffset: CGPoint) {

        contentOffsetViewTopConstraints?.isActive = false
        contentOffsetViewViewHeightConstraints?.isActive = false

        contentOffsetViewTopConstraints = contentOffsetView
            .topAnchor
            .constraint(equalTo: tableView.topAnchor)

        if contentOffset.y < 0 {
            
            contentOffsetViewViewHeightConstraints = contentOffsetView
                .heightAnchor
                .constraint(equalToConstant: -contentOffset.y)
        } else {
            
            contentOffsetViewViewHeightConstraints = contentOffsetView
                .heightAnchor
                .constraint(equalToConstant: 0)
        }

        contentOffsetViewTopConstraints?.isActive = true
        contentOffsetViewViewHeightConstraints?.isActive = true

        view.layoutIfNeeded()
    }

    func changeBackViewHeightConstraint(contentOffset: CGPoint) {

        backViewTopConstraints?.isActive = false
        backViewHeightConstraints?.isActive = false

        if contentOffset.y < 0 {
            
            backViewTopConstraints = backView
                .topAnchor
                .constraint(equalTo: tableView.topAnchor, constant: -contentOffset.y)
        } else {
            
            backViewTopConstraints = backView
                .topAnchor
                .constraint(equalTo: tableView.topAnchor, constant: 0)
        }


        backViewHeightConstraints = backView
            .heightAnchor
            .constraint(equalToConstant: tableView.frame.height)

        backViewTopConstraints?.isActive = true
        backViewHeightConstraints?.isActive = true

        view.layoutIfNeeded()
    }
}

extension ListTableViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return locationArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let tripData = locationArray[section]
        
        return tripData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch locationArray[indexPath.section][indexPath.row].type {
            
        case .empty:
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: TripListTableViewCell.self),
                for: indexPath
            )
            
            guard let emptyCell = cell as? TripListTableViewCell else { return UITableViewCell() }
            
            emptyCell.isEmpty = true
            emptyCell.switchCellContent()
            emptyCell.selectionStyle = .none
            
            return emptyCell
            
        case .location:
            
            let datas = locationArray[indexPath.section]
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: TripListTableViewCell.self),
                for: indexPath
            )
            
            guard let listCell = cell as? TripListTableViewCell,
                indexPath.row < datas.count else {
                    
                    return cell
            }
            
            listCell.isEmpty = false
            listCell.switchCellContent()
            
            let placeID = datas[indexPath.row].location.photo
            listCell.listImage.image = photosDict[placeID]
            
            listCell.placeNameLabel.text = datas[indexPath.row].location.name
            listCell.addressLabel.text = datas[indexPath.row].location.address
            
            listCell.selectionStyle = .none
            return listCell
        }
    }
}

extension ListTableViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
        ) -> UIView? {
        
        if day == 0 {
            
            guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: String(describing: TriplistHeader.self)) as? TriplistHeader else { return UIView() }
            headerView.backgroundColor = UIColor.darkGray
            
            let date = dates[section]
            dateFormatter.dateFormat = Constants.completeDate
            let dateString = dateFormatter.string(from: date)
            
            headerView.dateTitleLabel.text = dateString
            headerView.dayLabel.text = String(describing: section + 1)
            
            return headerView
        } else {
            
            guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: String(describing: TriplistHeader.self)) as? TriplistHeader else { return UIView() }
            headerView.backgroundColor = UIColor.darkGray
            
            let date = dates[day - 1]
            dateFormatter.dateFormat = Constants.completeDate
            let dateString = dateFormatter.string(from: date)
            
            headerView.dateTitleLabel.text = dateString
            headerView.dayLabel.text = String(describing: day)
            
            return headerView
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
        ) -> CGFloat {
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.1
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        
        let datas = locationArray[indexPath.section]
        let location = datas[indexPath.row]
        
        guard location.type == .location else { return }
        
        delegate?.didShowDetail(location: location.location)
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
        ) -> UITableViewCell.EditingStyle {
        
        let type = locationArray[indexPath.section][indexPath.row].type
        
        guard type == .location else {
            
            return UITableViewCell.EditingStyle.none
        }
        
        return UITableViewCell.EditingStyle.delete
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard scrollView == tableView else { return }
        if scrollView.contentOffset.y > -contentOffsetViewVisiblewHeight {

            changeContentOffsetViewHeightConstraint(contentOffset: scrollView.contentOffset)
            changeBackViewHeightConstraint(contentOffset: scrollView.contentOffset)

        } else if  scrollView.contentOffset.y <= -contentOffsetViewVisiblewHeight {

            changeContentOffsetViewTopConstraint(contentOffset: scrollView.contentOffset)
            changeBackViewTopConstraint(contentOffset: scrollView.contentOffset)

            if scrollView.contentOffset.y < -(contentOffsetViewVisiblewHeight * 1.4) {

                handleTableVIewList(isHidding: true)
            }
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
        ) {

        if editingStyle == .delete {

            let location = locationArray[indexPath.section][indexPath.row].location

            locationArray[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if locationArray[indexPath.section].count == 0 {

                locationArray[indexPath.section].append(THdata(location: Location.emptyLocation(), type: .empty))
                let newIndexPath = IndexPath(row: 0, section: indexPath.section)
                tableView.insertRows(at: [newIndexPath], with: .none)
            }
            delegate?.didDeleteData(locationArray: locationArray, location: location)
        }
    }
}

// MARK: - Long press gesture to swap table view cell

extension ListTableViewController {
    
    @objc func longPressGestureRecognized(longPress: UILongPressGestureRecognizer) {
        
        let state = longPress.state
        
        let location = longPress.location(in: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: location) else {
            
            let numbers = locationArray[0].count
            
            for number in 0 ..< numbers where locationArray[0][number].type == .empty {
                
                locationArray[0].remove(at: number)
                let indexPath = IndexPath(row: number, section: 0)
                tableView.deleteRows(at: [indexPath], with: .none)
            }
            
            cleanUp()
            
            return
        }
        
        switch state {
            
        case .began:
            
            guard locationArray[indexPath.section][indexPath.row].type == .location else {
                return }
            
            sourceIndexPath = indexPath
            guard let cell = self.tableView.cellForRow(at: indexPath) as? TripListTableViewCell else {
                return }
            
            snapshot = customSnapshotFromView(inputView: cell)
            
            guard let snapshot = self.snapshot else {
                return }
            
            var center = cell.center
            snapshot.center = center
            snapshot.alpha = 0.0
            self.tableView.addSubview(snapshot)
            
            // Insert empty cell for one row's section
            
            if self.locationArray[indexPath.section].count == 1 {
                
                self.locationArray[indexPath.section].append(THdata(location: Location.emptyLocation(), type: .empty))
                let indexPath = IndexPath(row: 1, section: indexPath.section)
                self.tableView.insertRows(at: [indexPath], with: .none)
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                center.y = location.y
                snapshot.center = center
                snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                snapshot.alpha = 0.98
                cell.alpha = 0.0
                
            }, completion: { (finished) in
                if finished {
                    
                    cell.isHidden = true
                }
            })
            
        case .changed:
            
            guard let snapshot = snapshot else {
                return }
            
            var center = snapshot.center
            center.y = location.y
            snapshot.center = center
            
            guard let sourceIndexPath = self.sourceIndexPath else {
                return
            }
            
            if indexPath != sourceIndexPath {
                
                let firstDay = sourceIndexPath.section
                let secondDay = indexPath.section
                
                let dataToMove = locationArray[firstDay][sourceIndexPath.row]
                locationArray[firstDay].remove(at: sourceIndexPath.row)
                locationArray[secondDay].insert(dataToMove, at: indexPath.row)
                
                tableView.moveRow(at: sourceIndexPath, to: indexPath)
                self.sourceIndexPath = indexPath
            }
            
        default:
            
            guard let sourceIndexPath = self.sourceIndexPath else {
                return
            }
            
            var sourceIndex = sourceIndexPath
            
            // Check empty cell in section and remove it
            
            let numbers = locationArray[indexPath.section].count
            
            for number in 0 ..< numbers where locationArray[indexPath.section][number].type == .empty {
                
                locationArray[indexPath.section].remove(at: number)
                let indexPath = IndexPath(row: number, section: indexPath.section)
                
                tableView.deleteRows(at: [indexPath], with: .none)
                
                let newIndexPath = IndexPath(row: 0, section: indexPath.section)
                sourceIndex = newIndexPath
                
                break
            }
            
            guard let cell = self.tableView.cellForRow(at: sourceIndex) as? TripListTableViewCell else {
                
                cleanUp()
                return
            }
            
            guard let snapshot = self.snapshot else {
                return
            }
            
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: {
                snapshot.center = cell.center
                snapshot.transform = .identity
                snapshot.alpha = 0.0
                cell.alpha = 1.0
                
            }, completion: { (finished) in
                if finished {
                    
                    self.cleanUp()

                    self.delegate?.didUpdateData(locationArray: self.locationArray)
                }
            })
        }
    }
    
    func cleanUp() {
        
        sourceIndexPath = nil
        snapshot?.removeFromSuperview()
        snapshot = nil
        tableView.reloadData()
    }
    
    func customSnapshotFromView(inputView: UIView) -> UIView? {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        
        if let currentContext = UIGraphicsGetCurrentContext() {
            inputView.layer.render(in: currentContext)
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        UIGraphicsEndImageContext()
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        
        return snapshot
    }
}
