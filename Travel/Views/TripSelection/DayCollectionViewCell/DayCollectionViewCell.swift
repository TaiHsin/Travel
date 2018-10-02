//
//  DayCollectionViewCell.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/30.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class DayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var numberLabel: UILabel!
    
    var tapped: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 10
        cellView.layer.borderColor = UIColor.darkGray.cgColor
        cellView.layer.borderWidth = 2
        
    }
}
