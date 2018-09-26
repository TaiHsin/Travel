//
//  ReferenceData.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/25.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation
import UIKit
import MapKit

struct TripData {
    
    var title: String
    
    var image: String
    
    var durationTime: String
    
    var day: Day
    
}

struct Day {
    
    var date: String
    
    var placeName: String
    
    var latitude: String
    
    var longtitude: String
    
}

struct LocationData {
    
//    var placeName: String = "Effel Tower"
    var placeName: String
    
    var photo: UIImage
    
    var address: String
    
    var latitude: Double
    
    var longitude: Double
    

    
//    var address: String
    
//    var coordinate: CLLocationCoordinate2D
    
//    var latitude: Double = 48.858539
    
//    var longitude: Double = 2.294524
}

struct CellData {
    
    var opened: Bool
    
    var title: String
     
    var sectionData: [String]
}
