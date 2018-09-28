//
//  PreservedViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/27.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class PreservedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var locationData = [LocationData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationData = [LocationData(placeName: "Effel Tower", photo: #imageLiteral(resourceName: "paris"), address: "91A Rue de Rivoli, 75001 Paris, France", latitude: 48.858539, longitude: 2.294524),
                        LocationData(placeName: "Arc de Triomphe", photo: #imageLiteral(resourceName: "Arc_de_Triomphe"), address: "Place Charles de Gaulle, 75008 Paris, France", latitude: 48.873982, longitude: 2.295457),
                        LocationData(placeName: "Notre-Dame de Paris", photo: #imageLiteral(resourceName: "notre_dame_de_paris"), address: "6 Parvis Notre-Dame - Pl. Jean-Paul II, 75004 Paris, France", latitude: 48.853116, longitude: 2.349924),
                        LocationData(placeName: "Palais du Louvre", photo: #imageLiteral(resourceName: "palais_du_louvre"), address: "91A Rue de Rivoli, 75001 Paris, France", latitude: 48.860533, longitude: 2.338588)
        ]
        
        setupTableView()
        
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPressGestureRecognized(gestureRecognizer: ))
        )
        
        self.tableView.addGestureRecognizer(longPress)
    }
    
    func setupTableView() {
        
        let xib = UINib(
            nibName: String(describing: PreservedTableViewCell.self),
            bundle: nil
        )
        
        tableView.register(xib, forCellReuseIdentifier: String(describing: PreservedTableViewCell.self))
        
        tableView.delegate = self
        
        tableView.dataSource = self
    }
    
    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        
        guard let longPress = gestureRecognizer as? UILongPressGestureRecognizer else { return }
        
        let state = longPress.state
        
        let locationInView = longPress.location(in: self.tableView)
        
        var indexPath = self.tableView.indexPathForRow(at: locationInView)
        
        switch state {
            
        case .began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                guard let cell = self.tableView.cellForRow(at: indexPath!) as? PreservedTableViewCell else {
                    return
                }
                
                Path.cellSnapShot = snapshopOfCell(inputView: cell)
                var center = cell.center
                Path.cellSnapShot?.center = center
                Path.cellSnapShot?.alpha = 0.0
                self.tableView.addSubview(Path.cellSnapShot!)
                
                UIView.animate(withDuration: 0.25, animations: {
                    center.y = locationInView.y
                    Path.cellSnapShot?.center = center
                    Path.cellSnapShot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    Path.cellSnapShot?.alpha = 0.98
                    cell.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        cell.isHidden = true
                    }
                })
            }
        case .changed:
            
            var center = Path.cellSnapShot?.center
            center?.y = locationInView.y
            Path.cellSnapShot?.center = center!
            if indexPath != nil && indexPath != Path.initialIndexPath {
                
                self.locationData.swapAt((indexPath?.row)!, (Path.initialIndexPath?.row)!)
                
                self.tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                Path.initialIndexPath = indexPath
            }
        default:
            
            guard let cell = self.tableView.cellForRow(at: Path.initialIndexPath!) as? PreservedTableViewCell else {
                return
            }
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: {
                Path.cellSnapShot?.center = cell.center
                Path.cellSnapShot?.transform = .identity
                Path.cellSnapShot?.alpha = 0.0
                cell.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    Path.cellSnapShot?.removeFromSuperview()
                    Path.cellSnapShot = nil
                }
            })
        }
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        let cellSnapshot: UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false

//        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
//        cellSnapshot.layer.shadowRadius = 5.0
//        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}

extension PreservedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return locationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: PreservedTableViewCell.self),
            for: indexPath) as? PreservedTableViewCell else {
            return UITableViewCell()
        }
        
        cell.photoImage.image = locationData[indexPath.row].photo
        
        cell.placeName.text = locationData[indexPath.row].placeName
        
//        cell.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        
//        cell.setSelected(true, animated: true)
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
        ) {
        
        if editingStyle == .delete {
            
            locationData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
            // TODO
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
}

extension PreservedViewController: UITableViewDelegate {
   
}
