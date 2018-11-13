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
        
        cellView.layer.cornerRadius = 5
        
        cellView.layer.borderWidth = 1
        
        cellView.layer.borderColor = #colorLiteral(red: 0.4235294118, green: 0.4588235294, blue: 0.5607843137, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
