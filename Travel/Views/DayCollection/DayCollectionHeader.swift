//
//  DayCollectionHeader.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/22.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

protocol DayHeaderDelegate: AnyObject {
    
    func showTriplist(for header: DayCollectionHeader)
}

class DayCollectionHeader: UICollectionReusableView {

    @IBOutlet weak var selectedView: UIView!
    
    @IBOutlet weak var headerButton: UIButton!
    
    @IBAction func tapHeader(_ sender: UIButton) {
        
        delegate?.showTriplist(for: self)
    }
    
    weak var delegate: DayHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedView.layer.cornerRadius = 4.0
        
        selectedView.layer.masksToBounds = true
        
        selectedView.isHidden = true
    }
    
}
