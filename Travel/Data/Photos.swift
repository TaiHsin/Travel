//
//  Photos.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/16.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation

class Photos {
    
    var photos: [String] = []
    
    init() {
        
        for index in 1 ... 20 {
            
            let string = "trip_" + String(describing: index)
            
            photos.append(string)
        }
    }
}
