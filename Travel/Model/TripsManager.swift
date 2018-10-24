//
//  placeDataManager.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/3.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Firebase
import FirebaseDatabase
import KeychainAccess

class TripsManager {
    
    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }
    
    let keychain = Keychain(service: "com.TaiHsinLee.Travel")
    
    let photoStrArray = Photos().photos
    
    let decoder = JSONDecoder()
    
    var sorted: [String: Any] = [:]
    
    // MARK: - Fetch MyTrip data
    
    func fetchTripsData(
        success: @escaping ([Trips]) -> Void,
        failure: @escaping (Error) -> Void
        ) {
        
        var datas: [Trips] = []
        
        guard let uid = keychain["userId"] else {
            
            NotificationCenter.default.post(name: Notification.Name("failure"), object: nil)
            
            return
        }
        
        #warning ("better way? observeSingleEvent first and then obeserve for .childAdd ?")
        
        /// Need to add sorting method by startDate!!!
        
        ref.child("myTrips")
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: uid)
            .observeSingleEvent(of: .value, with: { (snapshot) in
            
                guard let value = snapshot.value as? NSDictionary else {
                    
                    self.ref.child("/myTrips/defaultTrip").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        guard let value = snapshot.value as? NSDictionary else { return }
                        
                        guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else { return }
                        
                        do {
                            let data = try self.decoder.decode(Trips.self, from: jsonData)
                            
                            self.createTripData(
                                name: data.name,
                                place: data.place,
                                startDate: data.startDate,
                                endDate: data.endDate,
                                totalDays: data.totalDays,
                                createdTime: data.createdTime,
                                success: { (daysKey, key) in
                                    
                                    self.fetchDayList(daysKey: data.daysKey, success: { (locations) in
//
//                                        self.addDefauleData(dayskey: daysKey, locations: locations)
//
//                                        self.fetchTripsData(success: { (datas) in
//
//                                            success(datas)
//                                        }, failure: { (_) in
//                                            // TODO
//                                        })
                                    })
                            })
                            
//                            datas.append(data)
                        } catch {
                            print(error)
                            failure(error)
                        }
                    })
                
                NotificationCenter.default.post(name: Notification.Name("failure"), object: nil)
                
                return
            }
            
            for value in value.allValues {
                
                guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else { return }
                
                do {
                    let data = try self.decoder.decode(Trips.self, from: jsonData)
                    
                    datas.append(data)
                } catch {
                    print(error)
                    failure(error)
                }
            }
            success(datas)
        })
    }
    
    /// Try to use model to replace
    func createTripData(
        name: String,
        place: String,
        startDate: Double,
        endDate: Double,
        totalDays: Int,
        createdTime: Double,
        success: @escaping (String, String) -> Void
        ) {
        
        // Add daysKey for tripDays node
        
        guard let daysKey = ref.child("tripDays").childByAutoId().key else { return }
        guard let key = ref.child("myTrips").childByAutoId().key else { return }
        
        guard let uid = keychain["userId"] else { return }
        
        let post = ["name": name,
                    "place": place,
                    "startDate": startDate,
                    "endDate": endDate,
                    "totalDays": totalDays,
                    "createdTime": createdTime,
                    "id": key,
                    "placePic": photoStrArray.randomElement(),
                    "daysKey": daysKey,
                    "userId": uid
            ] as [String: Any]
        
        let postUpdate = ["/myTrips/\(key)": post]
        ref.updateChildValues(postUpdate)
        
        success(daysKey, key)
    }
    
    // MARK: - Fetch Triplist data (once for all)
    
    func fetchDayList(daysKey: String, success: @escaping ([THdata]) -> Void) {
        
        let location: Location = Location.emptyLocation()
        
        ref.child("tripDays").child("\(daysKey)").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? NSDictionary else {
                
                let result = THdata(location: location, type: .empty)
                
                success([result])
                
                return
            }
            
            var result: [THdata] = []
            
            for value in value.allValues {
                guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else { return }

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
    
    // MARK: - Delete MyTrip data
    
    func deleteMyTrip(tripID: String, daysKey: String) {
        
        ref.child("/myTrips/\(tripID)").removeValue()
        ref.child("/tripDays/\(daysKey)").removeValue()
    }
    
    func addDefauleData(dayskey: String, locations: [Location]) {
        
        for location in locations {
            
            guard let locationId = self.ref.child("/tripDays/\(dayskey)").childByAutoId().key else { return }
            
            let post = ["addTime": location.addTime,
                        "address": location.address,
                        "latitude": location.latitude,
                        "longitude": location.longitude,
                        "locationId": locationId,
                        "name": location.name,
                        "order": location.order,
                        "photo": location.photo,
                        "days": location.days,
                        "position": location.position
                ] as [String: Any]
            
            let postUpdate = ["/tripDays/\(dayskey)/\(locationId)": post]
            
            ref.updateChildValues(postUpdate)
        }
    }
}
