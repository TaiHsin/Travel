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
    
    let daysKey: String
    
    let placePic: String
    
    let id: String
    
    let userId: String
}

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
    
    var position: String
    
    static func emptyLocation() -> Location {
        
        return Location(
            addTime: 0.0,
            address: "",
            latitude: 0,
            longitude: 0,
            locationId: "",
            name: "",
            order: 0,
            photo: "",
            days: 0,
            position: "0_0"
        )
    }
}

enum LocationCellType {
    
    case empty
    
    case location
}

struct THdata {
    
    var location: Location
    
    let type: LocationCellType
}
