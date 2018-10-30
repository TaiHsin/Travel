//
//  FirebaseManager.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/30.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseManager {
    
    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }
    
    func deleteDay(daysKey: String, day: Int) {
        
        ref.child("tripDays")
            .child(daysKey)
            .queryOrdered(byChild: "days")
            .queryEqual(toValue: day)
            .observeSingleEvent(of: .value) { (snapshot) in
                guard let value = snapshot.value as? NSDictionary else { return }
                guard let keys = value.allKeys as? [String] else { return }
                
                for key in keys {
                    self.ref.child("/tripDays/\(daysKey)/\(key)").removeValue()
                }
        }
    }
    
    func deleteLocation(daysKey: String, location: Location) {
        
        ref.child("tripDays")
            .child(daysKey)
            .queryOrdered(byChild: "locationId")
            .queryEqual(toValue: location.locationId)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else { return }
                guard let key = value.allKeys.first as? String else { return }
                self.ref.child("/tripDays/\(daysKey)/\(key)").removeValue()
        }
    }
}
