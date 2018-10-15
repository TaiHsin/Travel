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
    
    @IBOutlet weak var locationImage: UIImageView!
    
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    var isEmpty = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        switchCellContent()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func switchCellContent() {
        
//        if isEmpty {
        
            emptyLabel.isHidden = !isEmpty
            listImage.isHidden = isEmpty
            addressLabel.isHidden = isEmpty
            placeNameLabel.isHidden = isEmpty
            locationImage.isHidden = isEmpty
            
//        } else {
//
//            emptyLabel.isHidden = true
//            listImage.isHidden = false
//            addressLabel.isHidden = false
//            placeNameLabel.isHidden = false
//            locationImage.isHidden = false
//        }
    }
}
