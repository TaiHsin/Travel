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
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    var flag = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        switchCellContent()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func switchCellContent() {
        
        if flag {
            
            emptyLabel.isHidden = true
            listImage.isHidden = false
            addressLabel.isHidden = false
            placeNameLabel.isHidden = false
        } else {
            
            emptyLabel.isHidden = false
            listImage.isHidden = true
            addressLabel.isHidden = true
            placeNameLabel.isHidden = true
        }
    }
}
