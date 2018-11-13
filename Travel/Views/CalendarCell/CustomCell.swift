//
//  CellView.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/1.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CustomCell: JTAppleCell {

    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var selectedView: UIView!
    
    @IBOutlet weak var leftView: UIView!
    
    @IBOutlet weak var rightView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
