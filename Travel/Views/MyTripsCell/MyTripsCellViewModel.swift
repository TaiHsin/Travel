//
//  MyTripsCellViewModel.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/12/7.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation
import UIKit

class MyTripsCellViewModel {
    
    let pictureID: String
    
    let place: String
    
    let startDate: Double
    
    let endDate: Double
    
    init(trip: Trips) {
        
        self.pictureID = trip.placePic
        self.place = trip.place
        self.startDate = trip.startDate
        self.endDate = trip.endDate
    }
}



