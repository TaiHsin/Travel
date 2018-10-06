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
    
    var datas: [Trips] = []
    
    var details: [Details] = []
    
    var sorted: [String: Any] = [:]
    
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
            let daysUpdate = ["/tripDays/\(daysKey)/Day\(day)": addDays]
            
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
    
    func fetchDayList(daysKey: String, success: @escaping ([String: Any]) -> Void) {
        
        ref.child("tripDays").child("\(daysKey)").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? [String: Any] else { return }
            
            print(value)
            let sortedDict = value.sorted(by: { (firstDictionary, secondDictionary) -> Bool in
                
                let firstKey = firstDictionary.0
                let firstKeyIndex = firstKey.index(firstKey.startIndex, offsetBy: 3)
                
                let firstKeyRealValue = Int(String(firstKey[firstKeyIndex...]))
                
                ///String slicing subscript with a 'partial range from' operator
                
                let secondKey = secondDictionary.0
                let secondKeyIndex = secondKey.index(secondKey.startIndex, offsetBy: 3)
                
                let secondKeyRealValue = Int(String(secondKey[secondKeyIndex...]))
                
                return firstKeyRealValue! < secondKeyRealValue!
            })
            
            print(sortedDict)
            
            //            for (index, item) in sortedDict.enumerated() {
            //
            //                var dictionary: [String: Any] = [:]
            //
            //                dictionary[item.key] = item.value as? NSDictionary
            //
            //                guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary) else { return }
            //
            //                do {
            //                    let data = try self.decoder.decode(Details.self, from: jsonData)
            //
            //                    print(self.datas)
            //                    self.details.append(data)
            //
            //
            //
            //                } catch {
            //                    print(error)
            //                }
            success(value)
        }
        
    }
}

