//
//  CollectionHeader.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/2.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import JTAppleCalendar

class CalendarHeader: JTAppleCollectionReusableView {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    func showDate(from date: String) {
        
        dateLabel.text = "MMMM" + " " + "YYYY"
    }
}
