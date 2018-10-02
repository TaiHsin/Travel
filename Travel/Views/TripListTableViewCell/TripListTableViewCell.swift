//
//  TripListTableViewCell.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/26.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class TripListTableViewCell: UITableViewCell {

    @IBOutlet weak var listImage: UIImageView!
    
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
