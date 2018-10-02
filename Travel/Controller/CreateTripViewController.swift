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
        calendarView.scrollToDate(Date())
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
        
        // Setup labels
        // Due to calendarView is not setup yet, we use closure to handle with it
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewOfCalendar(from: visibleDates)
        }
    }
    
    func handleCellTextColor(cell: JTAppleCell?, cellState: CellState) {

        guard let validCell = cell as? CustomCell else { return }

        if cellState.isSelected {
            validCell.dateLabel.textColor = selectedMonthColor
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = monthColor
            } else {
                validCell.dateLabel.textColor = outsideMonthColor
            }
        }
    }
    
    func handleCellSelected(cell: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = cell as? CustomCell else { return }
        
        switch cellState.selectedPosition() {
        
        case .full:
            validCell.selectedView.isHidden = false
            validCell.selectedView.backgroundColor = UIColor.darkGray
            validCell.leftView.isHidden = true
            validCell.rightView.isHidden = true
            
        case .left:
            if cellState.dateBelongsTo != .thisMonth {
                validCell.rightView.isHidden = true
            } else {
                validCell.rightView.isHidden = false
            }
            validCell.selectedView.backgroundColor = UIColor.darkGray
            
        case .right:
            if cellState.dateBelongsTo != .thisMonth {
                validCell.leftView.isHidden = true
            } else {
                validCell.leftView.isHidden = false
            }
            validCell.selectedView.isHidden = false
            validCell.selectedView.backgroundColor = UIColor.darkGray
            
        case .middle:
            validCell.leftView.isHidden = false
            validCell.rightView.isHidden = false
            validCell.selectedView.isHidden = true
            validCell.selectedView.backgroundColor = UIColor.lightGray
        default:
            validCell.selectedView.isHidden = true
            validCell.rightView.isHidden = true
            validCell.leftView.isHidden = true
        }
    }
    
    func setupViewOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        formatter.dateFormat = "MMMM YYYY"
        monthLabel.text = formatter.string(from: date)
    }
}

extension CreateTripViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        /// What guard let should return to avoid force unwrapped?
        
        let startDate = formatter.date(from: "2018 04 01")!
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
        handleCellSelected(cell: cell, cellState: cellState)
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
        
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.isHidden = false
            cell.leftView.isHidden = true
            cell.rightView.isHidden = true
        } else {
            cell.dateLabel.isHidden = true
            cell.leftView.isHidden = true
            cell.rightView.isHidden = true
        }
        
//        handleCellSelected(cell: cell, cellState: cellState)
//        handleCellTextColor(cell: cell, cellState: cellState)
        
//        handleCellSelected(cell: cell, cellState: cellState)
        
        return cell
    }
    
    func calendar(
        _ calendar: JTAppleCalendarView,
        didSelectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
        ) {
        
//        handleCellSelected(cell: cell, cellState: cellState)
//        handleCellTextColor(cell: cell, cellState: cellState)
        
        if cellState.dateBelongsTo == .thisMonth {
            if firstDate != nil {
                
                if tapped == false {
                    
                    // TODO: reset all selected color
                    calendarView.deselectDates(from: firstDate!, to: lastDate!, triggerSelectionDelegate: false)
                    
                    firstDate = date
                    tapped = true
                    
                } else if date < firstDate! {
                    
                    calendarView.deselectDates(from: firstDate!, to: lastDate!, triggerSelectionDelegate: false)
                    firstDate = date
                    tapped = true
                    
                } else {
                    lastDate = date
                    tapped = false
                    
                    calendarView.selectDates(
                        from: firstDate!,
                        to: lastDate!,
                        triggerSelectionDelegate: false,
                        keepSelectionIfMultiSelectionAllowed: true
                    )
                }
                
            } else {
                firstDate = date
                //            lastDate = date
                tapped = true
            }
        } else {
            calendarView.deselectDates(from: date)
        }
        
        handleCellSelected(cell: cell, cellState: cellState)
        cell?.layoutIfNeeded()
    }
    
    func calendar(
        _ calendar: JTAppleCalendarView,
        didDeselectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
        ) {
        
        if lastDate != nil {
        calendarView.deselectDates(from: firstDate!, to: lastDate!, triggerSelectionDelegate: false)
        }
//        firstDate = date
        handleCellSelected(cell: cell, cellState: cellState)
        
        cell?.layoutIfNeeded()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        setupViewOfCalendar(from: visibleDates)
    }
 
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
