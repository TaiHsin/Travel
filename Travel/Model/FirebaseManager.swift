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

protocol FirebaseProtocol {

    func fetchData(
        path: String,
        success: @escaping (Any?) -> Void,
        failure: @escaping (TravelError) -> Void
    )
    
    func fetchDataWithQuery(
        path: String,
        child: String,
        value: Any?,
        success: @escaping (Any?) -> Void,
        failure: @escaping (TravelError) -> Void
    )
    
    func updateData(
        path: String,
        value: Any,
        success: @escaping () -> Void,
        failure: @escaping (TravelError) -> Void
    )
    
    func deleteData(
        path: String,
        success: @escaping () -> Void,
        failure: @escaping (TravelError) -> Void
    )
    
    func createAutoKey(path: String) -> String
}

class FirebaseManager: FirebaseProtocol {
    
    let photoStrArray = Photos().photos
    
    var ref: DatabaseReference!
    
    let decoder = JSONDecoder()
    
    let keychain = Keychain(service: "com.TaiHsinLee.Travel")
    
    init() {
        
        ref = Database.database().reference()
    }
    
    func fetchData(
        path: String,
        success: @escaping (Any?) -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        ref.child(path)
            .observeSingleEvent(
                of: .value,
                with: { (snapshot) in
                    
                    success(snapshot.value)
                    
            }, withCancel: { (_) in
                
                failure(TravelError.serverError)
            })
    }
    
    func fetchDataWithQuery(
        path: String,
        child: String,
        value: Any?,
        success: @escaping (Any?) -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        ref.child(path)
            .queryOrdered(byChild: child)
            .queryEqual(toValue: value)
            .observeSingleEvent(
                of: .value,
                with: { (snapshot) in
                    
                    success(snapshot.value)
                    
            }, withCancel: { (_) in
                
                failure(TravelError.serverError)
            })
    }
    
    func updateData(
        path: String,
        value: Any,
        success: @escaping () -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        ref.updateChildValues([path: value], withCompletionBlock: { (error, ref) in
            
            print(error as Any, ref)
            
            if let error = error {
                
                print(error.localizedDescription)
                
                failure(TravelError.serverError)
            } else {
                
                success()
            }
        })
    }
    
    func deleteData(
        path: String,
        success: @escaping () -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        ref.child(path).removeValue(completionBlock: { (error, ref) in
            
            print(error as Any, ref)
            
            if let error = error {
                
                print(error.localizedDescription)
                
                failure(TravelError.serverError)
            } else {
                
                success()
            }
        })
    }
    
    func createAutoKey(path: String) -> String {
        
        guard let key = self.ref.child("tripDays").childByAutoId().key else {
            
            return Constants.emptyString
        }
        
        return key
    }
}

// Refactoring
extension FirebaseManager {
    
    // MARK: - ChecklistViewController
    
    // NO QUERY: ref.child().observeSingleEvent
    func fetchChecklist(
        success: @escaping ([Checklist]) -> Void,
        failure: @escaping (TravelError) -> Void
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
                        
                        // Separate update method
                        
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
    
    // NO QUERY: ref.child().observeSingleEvent
    func fetchDefaultData(
        success: @escaping ([Checklist]) -> Void,
        failure: @escaping (TravelError) -> Void
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

extension FirebaseManager {
    
    // MARK: - MyTripViewController
    
    // QUERY: ref.child().queryOrdered().queryEqual().observeSingleEvent
    func fetchTripsData(
        success: @escaping ([Trips]) -> Void,
        failure: @escaping (Error) -> Void
        ) {
        
        var datas: [Trips] = []
        
        guard let uid = keychain["userId"] else {
            
            NotificationCenter.default.post(name: .failure, object: nil)
            
            return
        }
        
        // Better way? observeSingleEvent first and then obeserve for .childAdd ?
        
        ref.child("myTrips")
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: uid)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    // Create example trips for first user
                    
                    self.ref.child("/myTrips/defaultTrip").observeSingleEvent(
                        of: .value,
                        with: { [weak self] (snapshot) in
                            
                            guard let self = self else {
                                
                                return
                            }
                            
                            guard let value = snapshot.value as? NSDictionary else {
                                
                                return
                            }
                            
                            guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else {
                                
                                return
                            }
                            
                            do {
                                let data = try self.decoder.decode(Trips.self, from: jsonData)
                                
                                self.createTripData(
                                    trip: data,
                                    success: { [weak self] (daysKey, key, uid) in
                                        
                                        print(daysKey, key, uid)
                                        
                                        // Temporary
                                        self?.fetchTriplist(
                                            daysKey: data.daysKey,
                                            success: { [weak self]  (thData) in
                                                
                                                self?.addDefauleData(dayskey: daysKey, locations: thData)
                                                
                                                self?.fetchTripsData(success: { (datas) in
                                                    
                                                    success(datas)
                                                    
                                                }, failure: { (_) in
                                                    // TODO
                                                })
                                        },
                                            failure: { (error) in
                                                
                                                print(error.localizedDescription)
                                        })
                                })
                                
                            } catch {
                                
                                print(error)
                                
                                failure(error)
                            }
                    })
                    
                    NotificationCenter.default.post(name: .failure, object: nil)
                    
                    return
                }
                
                for value in value.allValues {
                    
                    guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else {
                        
                        return
                    }
                    
                    do {
                        let data = try self.decoder.decode(Trips.self, from: jsonData)
                        
                        datas.append(data)
                        
                    } catch {
                        
                        failure(error)
                    }
                }
                
                success(datas)
            })
    }
    
    func createTripData(
        trip: Trips,
        success: @escaping (String, String, String) -> Void
        ) {
        
        // Add daysKey for tripDays node
        
        guard let daysKey = ref.child("tripDays").childByAutoId().key else {
            
            return
        }
        
        guard let key = ref.child("myTrips").childByAutoId().key else {
            
            return
        }
        
        guard let uid = keychain["userId"] else {
            
            return
        }
        
        guard let placePic = photoStrArray.randomElement() else {
            
            return
        }
        
        let post = ["name": trip.name,
                    "place": trip.place,
                    "startDate": trip.startDate,
                    "endDate": trip.endDate,
                    "totalDays": trip.totalDays,
                    "createdTime": trip.createdTime,
                    "id": key,
                    "placePic": placePic,
                    "daysKey": daysKey,
                    "userId": uid
            ] as [String: Any]
        
        let postUpdate = ["/myTrips/\(key)": post]
        
        ref.updateChildValues(postUpdate)
        
        success(daysKey, key, uid)
    }
    
    func deleteMyTrip(tripID: String, daysKey: String) {
        
        ref.child("/myTrips/\(tripID)").removeValue()
        
        ref.child("/tripDays/\(daysKey)").removeValue()
    }
    
    func addDefauleData(dayskey: String, locations: [THdata]) {
        
        for location in locations {
            
            guard let locationId = self.ref.child("/tripDays/\(dayskey)").childByAutoId().key else {
                
                return
            }
            
            let post = ["addTime": location.location.addTime,
                        "address": location.location.address,
                        "latitude": location.location.latitude,
                        "longitude": location.location.longitude,
                        "locationId": locationId,
                        "name": location.location.name,
                        "order": location.location.order,
                        "photo": location.location.photo,
                        "days": location.location.days,
                        "position": location.location.position
                ] as [String: Any]
            
            let postUpdate = ["/tripDays/\(dayskey)/\(locationId)": post]
            
            ref.updateChildValues(postUpdate)
        }
    }
    
}

// MARK: - For refactor

enum FirebaseEventType {
    
    case valueChange
    
    func eventType() -> DataEventType {
        
        switch self {
            
        case .valueChange:
            
            return .value
        }
    }
}

extension FirebaseManager {
    
    // MARK: - TripListViewController(temp)
    
    func fetchTriplist(
        daysKey: String,
        success: @escaping ([THdata]) -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        let location: Location = Location.emptyLocation()
        
        let path = "/tripDays/\(daysKey)"
        
        fetchData(
            path: path,
            success: { (value) in
                
                guard let value = value as? NSDictionary else {
                    
                    let emptyResult = THdata(location: location, type: .empty)
                    
                    success([emptyResult])
                    
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
                        
                        print(TravelError.decodeError)
                    }
                }
                
                success(result)
        },
            failure: { (error) in
                
                failure(error)
        })
    }
}
