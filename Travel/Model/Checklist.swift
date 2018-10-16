//
//  Checklist.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/6.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation

struct Checklist: Codable {
    
    let category: String
    
    let id: String
    
    var items: [Items]
    
    var total: Int
}

struct Items: Codable {
    
    let name: String
    
    let number: Int
    
    var order: Int
    
    var isSelected: Bool
}
