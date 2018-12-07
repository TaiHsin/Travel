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
import KeychainAccess

class FirebaseManager {
    
    var ref: DatabaseReference!
    
    let decoder = JSONDecoder()
    
    let keychain = Keychain(service: "com.TaiHsinLee.Travel")
    
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
    
    // TripListViewController
    
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
        
        ref.updateChildValues(["/myTrips/\(id)/totalDays/": total])
        
        ref.updateChildValues(["/myTrips/\(id)/endDate/": end])
    }
    
    func updateAllData(trip: [Trips], data: [[THdata]]) {
        
        let daysKey = trip[0].daysKey
        
        let totalDays = trip[0].totalDays
        
        for day in 0 ... totalDays - 1 {
            
            data[day].forEach({ [weak self] (location) in
                
                let key = location.location.locationId
                
                if key != Constants.emptyString {
                    
                    let post = ["addTime": location.location.addTime,
                                "address": location.location.address,
                                "latitude": location.location.latitude,
                                "longitude": location.location.longitude,
                                "locationId": key,
                                "name": location.location.name,
                                "order": location.location.order,
                                "photo": location.location.photo,
                                "days": location.location.days,
                                "position": location.location.position
                        ] as [String: Any]
                    
                    let postUpdate = ["/tripDays/\(daysKey)/\(key)": post]
                    
                    self?.ref.updateChildValues(postUpdate)
                }
            })
        }
    }
    
    func deleteLocation(location: Location, trip: [Trips]) {
        
        let daysKey = trip[0].daysKey
        
        ref.child("tripDays")
            .child(daysKey)
            .queryOrdered(byChild: "locationId")
            .queryEqual(toValue: location.locationId)
            .observeSingleEvent(of: .value) { [weak self]  (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else { return }
                
                guard let key = value.allKeys.first as? String else { return }
                
                self?.ref.child("/tripDays/\(daysKey)/\(key)").removeValue()
        }
    }
    
    // TripSelectionViewController
    
    func checkLocationDays(daysKey: String, index: Int, location: Location) {
        
        guard daysKey != Constants.emptyString, index != 0 else {
            
            return
        }
        
        ref.child("/tripDays/\(daysKey)")
            .queryOrdered(byChild: "days")
            .queryEqual(toValue: index)
            .observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    self?.updataLocation(daysKey: daysKey, days: index, location: location)
                    
                    return
                }
                
                let order = value.count
                
                self?.updataLocation(
                    daysKey: daysKey,
                    order: order,
                    days: index,
                    location: location
                )
            })
    }
    
    func updataLocation(daysKey: String, order: Int = 0, days: Int, location: Location) {
        
        guard let key = self.ref.child("tripDays").childByAutoId().key else {
            
            return
        }
        
        let post = ["addTime": location.addTime,
                    "address": location.address,
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "locationId": key,
                    "name": location.name,
                    "order": order,
                    "photo": location.photo,
                    "days": days,
                    "position": location.position
            ] as [String: Any]
        
        let postUpdate = ["/tripDays/\(daysKey)/\(key)": post]
        
        ref.updateChildValues(postUpdate)
        
        NotificationCenter.default.post(name: .triplist, object: nil)
    }
    
    // PreservedViewController
    
    func deleteData(location: Location) {
        
        guard let uid = keychain["userId"] else { return }
        
        ref.child("/favorite/\(uid)")
            .queryOrdered(byChild: "locationId")
            .queryEqual(toValue: location.locationId)
            .observeSingleEvent(of: .value) { [weak self]  (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    return
                }
                
                guard let key = value.allKeys.first as? String else {
                    
                    return
                }
                
                self?.ref.child("/favorite/\(uid)/\(key)").removeValue()
        }
    }
    
    func fetchPreservedData(
        success: @escaping ([Location]) -> Void,
        failure: @escaping (Error) -> Void
        ) {
        
        var location: [Location] = []
        
        guard let uid = keychain["userId"] else {
            
            NotificationCenter.default.post(name: .noData, object: nil)
            
            return
        }
        
        ref.child("/favorite/\(uid)").observeSingleEvent(of: .value) { [weak self]  (snapshot) in
            
            guard let self = self else {
                
                return
            }
            
            guard let value = snapshot.value as? NSDictionary else {
                
                NotificationCenter.default.post(name: .noData, object: nil)
                
                return
            }
            
            for value in value.allValues {
                
                // Data convert: can be refact out independently
                
                guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else {
                    
                    return
                }
                
                do {
                    let data = try self.decoder.decode(Location.self, from: jsonData)
                    
                    location.append(data)
                    
                } catch {
                    
                    failure(error)
                }
            }
            
            success(location)
        }
    }
    
    // DetailViewController
    
    func updateLocation(
        location: Location,
        success: @escaping (Int) -> Void,
        failure: @escaping (Error) -> Void
        ) {
        
        guard let uid = keychain["userId"] else {
            
            return
        }
        
        ref.child("/favorite/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? NSDictionary else {
                
                return
            }
            
            success(value.allKeys.count)
        }
        
        guard let key = ref.child("favorite").childByAutoId().key else {
            
            return
        }
        
        let post = ["addTime": location.addTime,
                    "address": location.address,
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "locationId": key,
                    "name": location.name,
                    "order": location.order,
                    "photo": location.photo,
                    "days": location.days,
                    "position": location.position
            ] as [String: Any]
        
        let postUpdate = ["/favorite/\(uid)/\(key)": post]
        
        ref.updateChildValues(postUpdate)
    }
    
    func updateFavorite(
        location: Location,
        success: @escaping () -> Void,
        failure: @escaping () -> Void
        ) {
        
        guard let uid = keychain["userId"] else { return }
        
        ref.child("/favorite/\(uid)")
            .queryOrdered(byChild: "position")
            .queryEqual(toValue: location.position)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                if (snapshot.value as? NSDictionary) != nil {
                    
                    failure()
                    
                } else {
                    
                    success()
                }
        }
    }
    
    // SearchViewController
    
    func fetchDataCount(success: @escaping (Int) -> Void) {
        
        ref.child("favorite").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? NSDictionary else {
                
                return
            }
            
            let number = value.allKeys.count
            
            success(number)
        }
    }
    
    // ChecklistViewController
    
    func fetchChecklist(
        success: @escaping ([Checklist]) -> Void,
        failure: @escaping (TripsError) -> Void
        ) {
        
        guard let uid = keychain["userId"] else { return }
        
        ref.child("/checklist/\(uid)").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            
            guard let self = self else {
                
                return
            }
            
            guard let value = snapshot.value as? NSArray else {
                
                self.fetchDefaultData(success: { [weak self]  (data) in
                    
                    success(data)
                    
                    let numbers = data.count
                    
                    for number in 0 ... numbers - 1 {
                        
                        let post = [ "category": data[number].category,
                                     "id": data[number].id,
                                     "total": data[number].total
                            ] as [String: Any]
                        
                        let postUpdate = ["/checklist/\(uid)/\(number)": post]
                        
                        self?.ref.updateChildValues(postUpdate)
                        
                        let totals = data[number].items.count
                        
                        for index in 0 ... totals - 1 {
                            
                            let item = data[number].items[index]
                            
                            let post = ["name": item.name,
                                        "number": item.number,
                                        "order": item.order,
                                        "isSelected": item.isSelected
                                ] as [String: Any]
                            
                            let postUpdate = ["/checklist/\(uid)/\(number)/items/\(index)": post]
                            
                            self?.ref.updateChildValues(postUpdate)
                        }
                    }
                    
                    }, failure: { (error) in
                        
                        print(error)
                })
                
                return
            }
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: value) else { return }
            
            do {
                
                let data = try self.decoder.decode([Checklist].self, from: jsonData)
                
                success(data)
                
            } catch {
                // TODO: Error handling
                print(error)
            }
        }
    }
    
    func fetchDefaultData(
        success: @escaping ([Checklist]) -> Void,
        failure: @escaping (TripsError) -> Void
        ) {
        
        ref.child("/checklist/examplechecklist").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            
            guard let self = self else {
                
                return
            }
            
            guard let value = snapshot.value as? NSArray else {
                
                return
            }
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: value) else {
                
                return
            }
            
            do {
                let data = try self.decoder.decode([Checklist].self, from: jsonData)
                
                success(data)
                
            } catch {
                
                // TODO: Error handling
                
                print(error)
            }
        }
    }
    
    func deleteChecklist(path: String) {
        
        ref.child(path).removeValue()
    }
    
    func updateCheck(item: Items, indexPath: IndexPath) {
        
        guard let uid = keychain["userId"] else {
            
            return
        }
        
        if item.name == Constants.emptyString {
            
            let post = [
                "/checklist/\(uid)/\(indexPath.section)/items/\(indexPath.row)/isSelected": item.isSelected
            ]
            
            ref.updateChildValues(post)
        } else {
            
            let post = ["name": item.name,
                        "number": item.number,
                        "order": item.order,
                        "isSelected": item.isSelected
                ] as [String: Any]
            
            let postUpdate = ["/checklist/\(uid)/\(indexPath.section)/items/\(indexPath.row)": post]
            
            ref.updateChildValues(postUpdate)
        }
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
    
    //child(${path})
    
    func deleteLocationExample(daysKey: String, location: Location) {
        
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
