//
//  TravelColor.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/1.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let battleshipGrey = UIColor().colorFromHex("707589") // 112 117 137
    
    static let titleColor = UIColor().colorFromHex("6c758e") // 108 117 143
    
    static let cloudyBlue = UIColor().colorFromHex("abc4d7") // 170 196 216
    
    static let lightOrange = UIColor().colorFromHex("ffaa39") // 255 170 57
    
    func colorFromHex(_ hex: String) -> UIColor {
        
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            
            return UIColor.darkGray
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgbValue)
        
        return UIColor.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
