//
//  TriplistManager.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/12/8.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation

class TriplistManager {
    
    private let firebaseManager = FirebaseManager()
    
    private let decoder = JSONDecoder()
    
    func fetchTriplist(
        daysKey: String,
        success: @escaping ([THdata]) -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        let location: Location = Location.emptyLocation()
        
        let path = "/tripDays/\(daysKey)"
        
        firebaseManager.fetchData(
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
    
    func updateMyTrips(
        total: Int,
        end: Double,
        id: String,
        failure: @escaping (TravelError) -> Void
        ) {
        
        let pathForTotal = "/myTrips/\(id)/totalDays"
        
        firebaseManager.updateData(path: pathForTotal, value: total, failure: { (error) in
            
            failure(error)
        })
        
        let pathForEnd = "/myTrips/\(id)/endDate"
        
        firebaseManager.updateData(path: pathForEnd, value: end, failure: { (error) in
            
            failure(error)
        })
    }
    
    func updateTriplist(
        trip: [Trips],
        thDatas: [[THdata]],
        failure: @escaping (TravelError) -> Void
        ) {
        
        let daysKey = trip[0].daysKey
        
        let totalDays = trip[0].totalDays
        
        for day in 0 ... totalDays - 1 {
            
            thDatas[day].forEach({ (thData) in
                
                let key = thData.location.locationId
                
                if key != Constants.emptyString {
                    
                    let post = ["addTime": thData.location.addTime,
                                "address": thData.location.address,
                                "latitude": thData.location.latitude,
                                "longitude": thData.location.longitude,
                                "locationId": key,
                                "name": thData.location.name,
                                "order": thData.location.order,
                                "photo": thData.location.photo,
                                "days": thData.location.days,
                                "position": thData.location.position
                        ] as [String: Any]
                    
                    let path = "/tripDays/\(daysKey)/\(key)"
                    
                    firebaseManager.updateData(path: path, value: post, failure: { (error) in
                        
                        failure(error)
                    })
                }
            })
        }
    }
    
    func deleteTripDay(
        daysKey: String,
        day: Int,
        success: @escaping () -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        let path = "/tripDays/\(daysKey)"
        
        let child = "days"
        
        firebaseManager.fetchDataWithQuery(
            path: path,
            child: child,
            value: day,
            success: { [weak self] (value) in
                
                guard let value = value as? NSDictionary,
                    let keys = value.allKeys as? [String] else {
                        
                        failure(TravelError.fetchError)
                        
                        return
                }

                for key in keys {
                    
                    let path = "/tripDays/\(daysKey)/\(key)"
                    self?.firebaseManager.deleteData(path: path, failure: { (error) in
                        
                        failure(error)
                        })
                }
                
                success()
        },
            failure: { (error) in
                
                failure(error)
        })
    }
    
    func deleteTriplist(
        location: Location,
        trip: [Trips],
        success: @escaping () -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        let daysKey = trip[0].daysKey
        
        let path = "/tripDays/\(daysKey)"
        
        let child = "locationId"
        
        let value = location.locationId
        
        firebaseManager.fetchDataWithQuery(
            path: path,
            child: child,
            value: value,
            success: { [weak self] (value) in
                
                guard let value = value as? NSDictionary,
                    let key = value.allKeys.first as? String else {
                        return
                }
                
                let deletePath = "/tripDays/\(daysKey)/\(key)"
                
                self?.firebaseManager.deleteData(path: deletePath, failure: { (error) in
                    
                    failure(error)
                })
            },
            failure: { (error) in
                failure(error)
        })
    }
}
