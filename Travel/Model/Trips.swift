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

//struct Details: Codable {
//
//    let day: Days
//}

struct Details {
    
    var location: [Locations]?
    
    var isEmpty: Bool?
    
//    var day: String
}

struct Locations {
    
    var addTime: Int?
    
    var address: String?
    
    var latitude: Double?
    
    var longitude: Double?
    
    var locationId: String?
    
    var name: String?
    
    var order: Int?
    
    var photo: String?
}
