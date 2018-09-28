//
//  ChecklistFooterTableViewCell.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/28.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class ChecklistFooter: UITableViewCell {

    @IBOutlet weak var contentTextField: UITextField!
    
    @IBOutlet weak var addItemButton: UIButton!
    
    @IBAction func addItem(_ sender: UIButton) {
        
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        addItemButton.isHidden = false
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addItemButton.layer.cornerRadius = 5
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
}
