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

    var isTexting = false {
        didSet {
            addItemButton.isHidden = !isTexting
        }
    }

    /// Use UITextFieldDelegate to hide and show button (under investigation)
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        isTexting = contentTextField.isEditing
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        isTexting = !contentTextField.isEditing
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        addItemButton.layer.cornerRadius = 5
    }
}
