//
//  TripTableViewCell.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/30.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!

    var tapped: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 10
        cellView.layer.borderWidth = 2
        cellView.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
