//
//  MyTripsCollectionViewCell.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/25.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

protocol MyTripCellDelegate: AnyObject {
    
    func delete(for cell: MyTripsCell)
}

class MyTripsCell: UICollectionViewCell {

    @IBOutlet weak var tripImage: UIImageView!
    
    @IBOutlet weak var tripTitle: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var yearsLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var deleteLabel: UILabel!
    
    weak var delegate: MyTripCellDelegate?
    
    var isEditing = false {
        
        didSet {
        
            editingItem()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        editingItem()
    }
    
    func editingItem() {
        
        deleteLabel.isHidden = !isEditing
        
        deleteButton.isHidden = !isEditing
        
        dateLabel.isHidden = isEditing
        
        yearsLabel.isHidden = isEditing
    }
    
    @IBAction func deleteButtonDidTap(_ sender: Any) {
        
        delegate?.delete(for: self)
    }
}
