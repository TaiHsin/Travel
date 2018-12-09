//
//  THData.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/12/9.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation

struct THdata {
    
    var location: Location
    
    let type: LocationCellType
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
