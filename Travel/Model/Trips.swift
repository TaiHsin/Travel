//
//  TripPlans.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/3.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation

struct Trips: Codable {
    
    let place: String
    
    let startDate: Double
    
    let endDate: Double
    
    let totalDays: Int
    
    let createdTime: Double
    
    let daysKey: String?
    
    let placePic: String?
    
    let id: String
}

//struct tripsDays: Codable {
//    
//    
//}
