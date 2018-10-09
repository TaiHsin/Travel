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
    
    let endDate: Double
    
    let totalDays: Int
    
    let createdTime: Double
    
    let daysKey: String
    
    let placePic: String
    
    let id: String
}

//
//struct Details {
//    
//    var location: [Location]?
//    
//    var isEmpty: Bool?
//    
////    var day: String
//}

struct Location: Codable {
    
    var addTime: Double
    
    var address: String
    
    var latitude: Double
    
    var longitude: Double
    
    var locationId: String
    
    var name: String
    
    var order: Int
    
    var photo: String
    
    var days: Int
}
