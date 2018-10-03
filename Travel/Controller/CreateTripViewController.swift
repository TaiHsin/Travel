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
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    var tapped: Bool = false
    
    var firstDate: Date?
    
    var lastDate: Date?
    
    let formatter = DateFormatter()
    
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
//        formatter.dateFormat = "yyyy MM dd"
        let todayDateString = formatter.string(from: todaysDate)
        let monthsDateString = formatter.string(from: cellState.date)
        
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
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        /// What guard let should return to avoid force unwrapped?
        
        let startDate = Date()
        let endDate = formatter.date(from: "2020 12 31")!
        
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
        
        // TODO
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
        
        for date in calendar.selectedDates {
            
            formatter.dateFormat = "yyyy MM dd"
            print(formatter.string(from: date))
            //            print(date)
        }
        
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
        
        formatter.dateFormat = "MMMM yyyy"
        header.dateLabel.text = formatter.string(from: range.start)
        //        header.showDate(from: formatter.string(from: range.start))
        
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 30)
    }
}
