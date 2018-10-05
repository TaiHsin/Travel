//
//  CreateTripViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/28.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import JTAppleCalendar

// can delete after refactor
//import Firebase
//import FirebaseDatabase

class CreateTripViewController: UIViewController {
    
    @IBOutlet weak var placeTextField: UITextField!
    
    @IBOutlet weak var createTripButton: UIButton!
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBAction func backBottun(_ sender: UIBarButtonItem) {
        
        navigationController?.popViewController(animated: true)
    }
    
    var tapped: Bool = false
    
    var firstDate: Date?
    
    var lastDate: Date?
    
    let dateFormatter = DateFormatter()
    
    let tripManager = TripsManager()
    
    var selectedDates: [Date] = []
    
    let outsideMonthColor = UIColor.lightGray
    let monthColor = UIColor.darkGray
    let selectedMonthColor = UIColor.white
    let currentDateSelectedViewColor = UIColor.darkGray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createTripButton.layer.cornerRadius = 5
        
        // Scroll to present date
        //        calendarView.scrollToDate(Date(), extraAddedOffset: )
    }
    
    @IBAction func createNewTrip(_ sender: UIButton) {
        
        guard let place = placeTextField.text else {
            
            print("Please input Place or select dates")
            // TODO: showAlert
            
            return
        }
        
        guard let start = selectedDates.first else {
            
            print("Please input Place or select dates")
            // TODO: showAlert
            
            return
        }
        
        guard let theEnd = selectedDates.last else { return }
        let totalDays = selectedDates.count
        
        // DateFormatter need to refactor
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy mm dd"
        
        let startDate = Double(start.timeIntervalSince1970)
        let endDate = Double(theEnd.timeIntervalSince1970)
        
        // get current create time
        let currentDate = Date()
        let currenDateInt = Double(currentDate.timeIntervalSince1970)
        
        tripManager.createTripData(
            place: place,
            startDate: startDate,
            endDate: endDate,
            totalDays: totalDays,
            createdTime: currenDateInt
        ) { [weak self] (daysKey) in
            
            self?.switchViewController(key: daysKey)
        }
        
        placeTextField.text = ""
        selectedDates.removeAll()
    }
    
    func switchViewController(key: String) {
        
        guard let controller = UIStoryboard.myTripStoryboard()
            .instantiateViewController(
                withIdentifier: String(describing: TripListViewController.self)
            ) as? TripListViewController else { return }
        
        controller.daysKey = key
        
        show(controller, sender: nil)
    }
    
    /// To learn: How to get sender passed data by performSegue or show ？
    
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
    
    func setupCalendarView() {
        
        // Setup calendar spacing
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.cellSize = 44
        
        calendarView.allowsMultipleSelection = true
        calendarView.isRangeSelectionUsed = true
        
        self.calendarView.scrollingMode = .none
        
        // Setup labels
        // Due to calendarView is not setup yet, we use closure to handle with it
        
        //        calendarView.visibleDates { (visibleDates) in
        //            self.setupViewOfCalendar(from: visibleDates)
        //        }
    }
    
    /// Seems this func doesn't work
    func handleCellTextColor(cell: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = view as? CustomCell else { return }
        
        let todaysDate = Date()
        let todayDateString = dateFormatter.string(from: todaysDate)
        let monthsDateString = dateFormatter.string(from: cellState.date)
        
        if todayDateString == monthsDateString && cellState.dateBelongsTo == .thisMonth {
            
            validCell.dateLabel.textColor = UIColor.red
            
        } else if cellState.date < todaysDate && cellState.dateBelongsTo == .thisMonth {
            
            validCell.dateLabel.textColor = UIColor.lightGray
            
        } else {
            
            if cellState.isSelected {
                
                if cellState.dateBelongsTo == .thisMonth {
                    validCell.dateLabel.textColor = UIColor.white
                }
            } else {
                
                if cellState.dateBelongsTo == .thisMonth {
                    validCell.dateLabel.textColor = UIColor.black //self.monthColor
                } else {
                    validCell.dateLabel.textColor = UIColor.lightGray //self.outsideMonthColor
                }
            }
        }
    }
    
    func handleCellSelected(cell: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = cell as? CustomCell else { return }
        
        if cellState.isSelected && cellState.dateBelongsTo == .thisMonth {
            
            validCell.selectedView.isHidden = false
            
        } else {
            validCell.selectedView.isHidden = true
            validCell.leftView.isHidden = true
            validCell.rightView.isHidden = true
            
            validCell.dateLabel.isHidden = false
            validCell.dateLabel.textColor = UIColor.black
        }
    }
    
    func handleDateRangeSelection(cell: JTAppleCell?, cellState: CellState) {
        
        guard let cell = cell as? CustomCell else { return }
        
        if calendarView.allowsMultipleSelection {
            
            if cellState.isSelected {
                
                switch cellState.selectedPosition() {
                    
                case .full:
                    
                    cell.selectedView.backgroundColor = UIColor.darkGray
                    cell.leftView.isHidden = true
                    cell.rightView.isHidden = true
                    cell.dateLabel.textColor = UIColor.white
                    
                case .right:
                    
                    cell.leftView.isHidden = false
                    cell.selectedView.backgroundColor = UIColor.darkGray
                    cell.dateLabel.textColor = UIColor.white
                    
                case .left:
                    
                    cell.rightView.isHidden = false
                    cell.selectedView.backgroundColor = UIColor.darkGray
                    cell.dateLabel.textColor = UIColor.white
                    
                case .middle:
                    
                    cell.leftView.isHidden = false
                    cell.rightView.isHidden = false
                    cell.selectedView.backgroundColor = UIColor.darkGray
                    cell.dateLabel.textColor = UIColor.white
                    
                default:
                    
                    cell.leftView.isHidden = true
                    cell.rightView.isHidden = true
                    cell.selectedView.isHidden = true
                    cell.dateLabel.textColor = UIColor.black
                    
                }
            }
            
        }
    }
    
    //    func setupViewOfCalendar(from visibleDates: DateSegmentInfo) {
    //
    //        let date = visibleDates.monthDates.first!.date
    //
    //        formatter.dateFormat = "MMMM YYYY"
    //        monthLabel.text = formatter.string(from: date)
    //    }
}

extension CreateTripViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        /// What guard let should return to avoid force unwrapped?
        
        let startDate = Date()
        let endDate = dateFormatter.date(from: "2020 12 31")!
        
        let parameters = ConfigurationParameters(
            startDate: startDate,
            endDate: endDate,
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfRow,
            hasStrictBoundaries: true
        )
        
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
        
        // TODO: debug
        handleCellTextColor(cell: cell, cellState: cellState)
        
        handleCellSelected(cell: cell, cellState: cellState)
        handleDateRangeSelection(cell: cell, cellState: cellState)
        
        cell.layoutIfNeeded()
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
        
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleDateRangeSelection(cell: cell, cellState: cellState)
        
        if cellState.dateBelongsTo != . thisMonth {
            cell.isHidden = true
        } else {
            cell.isHidden = false
        }
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func calendar(
        _ calendar: JTAppleCalendarView,
        didSelectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
        ) {
        
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleDateRangeSelection(cell: cell, cellState: cellState)
        
        if firstDate != nil {
            if date < self.firstDate! {
                self.firstDate = date
            } else {
                self.lastDate = date
            }
            calendarView.selectDates(
                from: firstDate!,
                to: self.lastDate!,
                triggerSelectionDelegate: false,
                keepSelectionIfMultiSelectionAllowed: true
            )
            
        } else {
            firstDate = date
            self.lastDate = date
        }
        
        selectedDates = calendar.selectedDates
        
        cell?.layoutIfNeeded()
    }
    
    func calendar(
        _ calendar: JTAppleCalendarView,
        didDeselectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
        ) {
        
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleDateRangeSelection(cell: cell, cellState: cellState)
        
        self.calendarView.deselectDates(from: self.firstDate!, to: self.lastDate!, triggerSelectionDelegate: false)
        
        if date != self.firstDate && date != self.lastDate {
            if date < self.firstDate! {
                self.firstDate = date
            } else {
                self.lastDate = date
            }
            
            calendarView.selectDates(
                from: firstDate!,
                to: self.lastDate!,
                triggerSelectionDelegate: false,
                keepSelectionIfMultiSelectionAllowed: true
            )
            
        } else {
            self.firstDate = nil
            self.lastDate = nil
        }
    }
    
    //    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    //
    //        setupViewOfCalendar(from: visibleDates)
    //    }
    
    // header
    
    func calendar(
        _ calendar: JTAppleCalendarView,
        headerViewForDateRange range: (start: Date, end: Date),
        at indexPath: IndexPath
        ) -> JTAppleCollectionReusableView {
        
        guard let header = calendarView.dequeueReusableJTAppleSupplementaryView(
            withReuseIdentifier: String(describing: CalendarHeader.self),
            for: indexPath
            ) as? CalendarHeader else {
                
                return JTAppleCollectionReusableView()
        }
        
        dateFormatter.dateFormat = "MMMM yyyy"
        header.dateLabel.text = dateFormatter.string(from: range.start)
        //        header.showDate(from: formatter.string(from: range.start))
        
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 30)
    }
}
