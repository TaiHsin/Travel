//
//  TripPlans.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/3.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation

struct Trips: Codable {
    
    var name: String
    
    let place: String
    
    let startDate: Double
    
    var endDate: Double
    
    var totalDays: Int
    
    let createdTime: Double
    
    var daysKey: String
    
    let placePic: String
    
    var id: String
    
    var userId: String
}
