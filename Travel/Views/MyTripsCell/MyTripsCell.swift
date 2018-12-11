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
    
    let dateFormatter = DateFormatter()
    
    var isEditing = false {
        
        didSet {
        
            editingItem()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        editingItem()
    }
    
    func setup(viewModel: MyTripsCellViewModel) {
        
        tripImage.image = UIImage(named: viewModel.pictureID)
        
        tripTitle.text = viewModel.place
        
        dateFormatter.dateFormat = "yyyy MM dd"
        
        let startDate = Date(timeIntervalSince1970: viewModel.startDate)
        
        let endDate = Date(timeIntervalSince1970: viewModel.endDate)
        
        dateFormatter.dateFormat = "yyyy"
        
        let startYear = dateFormatter.string(from: startDate)
        
        let endYear = dateFormatter.string(from: endDate)
        
        if startYear == endYear {
            
            yearsLabel.text = startYear
        } else {
            
            yearsLabel.text = startYear + " - " + endYear
        }
        
        dateFormatter.dateFormat = "MMM.dd"
        
        let startMonth = dateFormatter.string(from: startDate)
        
        let endMonth = dateFormatter.string(from: endDate)
        
        dateLabel.text = startMonth + " - " + endMonth
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
