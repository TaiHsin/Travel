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
    
    @IBOutlet weak var selectedView: UIView!
    
    let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        dayLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        weekLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
        
        selectedView.layer.cornerRadius = 4.0
        selectedView.layer.masksToBounds = true
        selectedView.isHidden = true
    }
    
    func convertWeek(date: Date) {
        
        dateFormatter.dateFormat = "EE dd"
        let dateString = dateFormatter.string(from: date)
        guard let first = dateString.first else { return }
        let stringFirst = String(first)
        weekLabel.isHidden = false
        
        if stringFirst == "S" {
            
            let range = (stringFirst as NSString).range(of: stringFirst)
            let attribute = NSMutableAttributedString.init(string: stringFirst)
            attribute.addAttribute(
                NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.8509803922, green: 0.6078431373, blue: 0.6117647059, alpha: 1),
                range: range
            )
            
            weekLabel.attributedText = attribute
        } else {
         
            weekLabel.text = String(first)
        }
    }
}
