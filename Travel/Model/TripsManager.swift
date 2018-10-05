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
    
    var datas: [ Trips] = []
    
    func fetchPlaceData(
        success: @escaping ([Trips]) -> Void,
        failure: @escaping (TripsError) -> Void
        ) {
    
        #warning ("better way? observeSingleEvent first and then obeserve for .childAdd ?")

        /// Need to add sorting method by startDate!!!
        
        ref.child("myTrips").queryOrdered(byChild: "startDate").observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }
            guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else { return }

                            do {
                                let data = try self.decoder.decode(Trips.self, from: jsonData)

                                print(self.datas)
                                self.datas.append(data)

                            } catch {
                                print(error)
                            }
            success(self.datas)
        }
        
        
//        ref.child("myTrips").queryOrdered(byChild: "startDate").observeSingleEvent(of: .value) { (snapshot) in
//
//            guard let value = snapshot.value as? NSDictionary else { return }
//
//            self.datas.removeAll()
//            
//            for value in value.allValues {
//
//                guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else { return }
//
//                do {
//                    let data = try self.decoder.decode(Trips.self, from: jsonData)
//
//                    self.datas.insert(data, at: 0)
//
//                } catch {
//                    print(error)
//                }
//            }
//            print(self.datas)
//            success(self.datas)
//        }
    }
    
    func createTripData(
        place: String,
        startDate: Double,
        endDate: Double,
        totalDays: Int,
        createdTime: Double,
        success: @escaping (String) -> Void
        ) {
        
        // Add data at tripDays node
        
        guard let daysKey = ref.child("tripDays").childByAutoId().key else { return }
        print(daysKey)
        
        for day in 1 ... totalDays {
            
            let addDays = [ "isEmpty": true ] as [String: Any]
//            let daysUpdate = ["/tripDays/\(daysKey)/Day\(day)": addDays]
            
            let daysUpdate = ["/tripDays/\(daysKey)/\(String(day))": addDays]
            
            ref.updateChildValues(daysUpdate)
        }
        
        // Add myTrips data
        
        guard let key = ref.child("myTrips").childByAutoId().key else { return }
        
        let post = ["place": place,
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
    
    // MARK: - Fetch trip list data
    
    func fetchDayList(daysKey: String) {
        
        ref.child("tripDays").child("\(daysKey)").observeSingleEvent(of: .value) { (snapshot) in
    
            guard let value = snapshot.value as? NSDictionary else { return }
            
            print(value)
        }
    }
}