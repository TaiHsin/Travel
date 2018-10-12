//
//  MenuBarCollectionViewCell.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/25.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class MenuBarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var weekLabel: UILabel!
    
    let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        dayLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        weekLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
    }
    
    func convertWeek(date: Date) {

        dateFormatter.dateFormat = "EE dd"
        let dateString = dateFormatter.string(from: date)
        guard let first = dateString.first else { return }
        
        weekLabel.text = String(first)
    }
}
