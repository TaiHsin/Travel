//
//  CreateTripViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/28.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CreateTripViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var createTripButton: UIButton!
    
//    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        setupCalendarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createTripButton.layer.cornerRadius = 5
    }
    
//    func setupCalendarView() {
//
//        let xib = UINib(nibName: String(describing: CustomCell.self), bundle: nil)
//
//        calendarView.register(xib, forCellWithReuseIdentifier: String(describing: CustomCell.self))
//
//        calendarView.ibCalendarDataSource = self
//        calendarView.ibCalendarDelegate = self
//    }
    
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

extension CreateTripViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        /// What guard let should return to avoid force unwrapped?
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2017 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        
        return parameters
    }
}

extension CreateTripViewController: JTAppleCalendarViewDelegate {
    
    func calendar(
        _ calendar: JTAppleCalendarView,
        willDisplay cell: JTAppleCell,
        forItemAt date: Date,
        cellState: CellState,
        indexPath: IndexPath
        ) {
        // TODO
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        cellForItemAt date: Date,
        cellState: CellState,
        indexPath: IndexPath
        ) -> JTAppleCell {
        
        guard let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: String(describing: CustomCell.self),
            for: indexPath) as? CustomCell else {
            return JTAppleCell()
        }
        
        cell.dateLabel.text = cellState.text
        
        return cell
    }
}
