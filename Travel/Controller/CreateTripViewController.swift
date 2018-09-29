//
//  CreateTripViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/28.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class CreateTripViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var createTripButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createTripButton.layer.cornerRadius = 5
    }
    
    @IBAction func createNewTrip(_ sender: UIButton) {
        
//        performSegue(withIdentifier: String(describing: TripDetailViewController.self), sender: nil)
        
        guard let controller = UIStoryboard.myTripStoryboard()
            .instantiateViewController(
                withIdentifier: String(describing: TripListViewController.self)
            ) as? TripListViewController else { return }
        
        show(controller, sender: nil)
        
        /// How to get sender passed data by performSegue or show ？
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case String(describing: TripListViewController.self):
            
            guard let detailController = segue.destination as? TripListViewController else {
                
                return
            }
            
            print(detailController)
            
        default:
            
            return super.prepare(for: segue, sender: sender)
        }
    }
}
