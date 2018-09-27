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
