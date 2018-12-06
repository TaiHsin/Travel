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
    
    let decoder = JSONDecoder()
    
    init() {
        
        ref = Database.database().reference()
    }
    
    // Delete
    
    func deleteDay(daysKey: String, day: Int) {
        
        ref.child("tripDays")
            .child(daysKey)
            .queryOrdered(byChild: "days")
            .queryEqual(toValue: day)
            .observeSingleEvent(of: .value) { [weak self] (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    return
                }
                
                guard let keys = value.allKeys as? [String] else {
                    
                    return
                }
                
                for key in keys {
                    
                    self?.ref.child("/tripDays/\(daysKey)/\(key)").removeValue()
                }
        }
    }
    
    //child(${path})
    
    func deleteLocation(daysKey: String, location: Location) {
        
        ref.child("tripDays")
            .child(daysKey)
            .queryOrdered(byChild: "locationId")
            .queryEqual(toValue: location.locationId)
            .observeSingleEvent(of: .value) { [weak self] (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    return
                }
                
                guard let key = value.allKeys.first as? String else {
                    
                    return
                }
                
                self?.ref.child("/tripDays/\(daysKey)/\(key)").removeValue()
        }
    }
    
    // Read Data

    func fetchDayList(daysKey: String, success: @escaping ([THdata]) -> Void) {
        
        let location: Location = Location.emptyLocation()
        
        // path for refactor: tripDays/\(daysKey)
        
        ref.child("tripDays").child("\(daysKey)").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            
            guard let self = self else {
                
                return
            }
            
            guard let value = snapshot.value as? NSDictionary else {
                
                let result = THdata(location: location, type: .empty)
                
                success([result])
                
                return
            }
            
            var result: [THdata] = []
            
            for value in value.allValues {
                
                guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else {
                    
                    return
                }
                
                do {
                    
                    let data = try self.decoder.decode(Location.self, from: jsonData)
                    
                    let thDAta = THdata(location: data, type: .location)
                    
                    result.append(thDAta)
                    
                } catch {
                    
                    print(error)
                }
            }
            
            success(result)
        }
    }
    
    func updateMyTrips(total: Int, end: Double, id: String) {
        
        //        let id = trip[0].id
        
        ref.updateChildValues(["/myTrips/\(id)/totalDays/": total])
        
        ref.updateChildValues(["/myTrips/\(id)/endDate/": end])
    }
}

// MARK: - For refactor

extension FirebaseManager {
    
    func getNoQuery(
        path: String,
        event: FirebaseEventType,
        success: @escaping (Any) -> Void,
        failure: @escaping (Error) -> Void
        ) {
        
        ref.child(path).observeSingleEvent(of: event.eventType(), with: { snapshot in
            
            guard let value = snapshot.value as? NSDictionary else {
                
                //TODO: Failure
                
                return
            }
            
            success(value)
        }) { (error) in
            
            print(error.localizedDescription)
            failure(error)
        }
    }
}

enum FirebaseEventType {
    
    case valueChange
    
    func eventType() -> DataEventType {
        
        switch self {
            
        case .valueChange:
            
            return .value
        }
    }
}
