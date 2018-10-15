//
//  placeDataManager.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/3.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Firebase
import FirebaseDatabase

class TripsManager {
    
    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }
    
    let decoder = JSONDecoder()
    
    var sorted: [String: Any] = [:]
    
    // MARK: - Fetch MyTrip data
    
    func fetchTripsData(
        success: @escaping ([Trips]) -> Void,
        failure: @escaping (TripsError) -> Void
        ) {
        
        var datas: [Trips] = []
        
        #warning ("better way? observeSingleEvent first and then obeserve for .childAdd ?")
        
        /// Need to add sorting method by startDate!!!
        
        // Re-write to use singleObserveEvent
        
        ref.child("myTrips").queryOrdered(byChild: "startDate")
            .observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? NSDictionary else { return }
            
            for value in value.allValues {
                
                guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else { return }
                
                do {
                    let data = try self.decoder.decode(Trips.self, from: jsonData)
                    
                    datas.append(data)
                } catch {
                    print(error)
                }
            }
            success(datas)
        }
    }
    
    /// Try to use model to replace
    func createTripData(
        name: String,
        place: String,
        startDate: Double,
        endDate: Double,
        totalDays: Int,
        createdTime: Double,
        success: @escaping (String) -> Void
        ) {
        
        // Add daysKey for tripDays node
        
        guard let daysKey = ref.child("tripDays").childByAutoId().key else { return }
        guard let key = ref.child("myTrips").childByAutoId().key else { return }
        
        let post = ["name": name,
                    "place": place,
                    "startDate": startDate,
                    "endDate": endDate,
                    "totalDays": totalDays,
                    "createdTime": createdTime,
                    "id": key,
                    "placePic": "urlnumber",
                    "daysKey": daysKey
            ] as [String: Any]
        
        let postUpdate = ["/myTrips/\(key)": post]
        ref.updateChildValues(postUpdate)
        
        success(daysKey)
    }
    
    // MARK: - Fetch Triplist data (once for all)
    
    func fetchDayList(daysKey: String, success: @escaping ([Location]) -> Void) {
        
        var location: [Location] = []
        
        ref.child("tripDays").child("\(daysKey)").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? NSDictionary else {
                
                // TODO: Handle empty data (performance)
                
                return
            }
            
            for value in value.allValues {
                guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else { return }

                do {
                    let data = try self.decoder.decode(Location.self, from: jsonData)

                    location.append(data)

                } catch {
                    print(error)
                }
            }
            
            success(location)
        }
    }
    
    // MARK: - Delete MyTrip data
    
    func deleteMyTrip(tripID: String, daysKey: String) {
        
        ref.child("/myTrips/\(tripID)").removeValue()
        ref.child("/tripDays/\(daysKey)").removeValue()
    }
}
