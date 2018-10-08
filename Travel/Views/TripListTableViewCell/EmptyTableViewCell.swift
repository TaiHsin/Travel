//
//  EmptyTableViewCell.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/8.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var emptyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
