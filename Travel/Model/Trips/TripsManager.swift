//
//  placeDataManager.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/3.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import KeychainAccess

class TripsManager {
    
    let keychain = Keychain(service: "com.TaiHsinLee.Travel")
    
    private let firebaseManager = FirebaseManager()
    
    private let decoder = JSONDecoder()

    func updateMyTrips(
        total: Int,
        end: Double,
        id: String,
        success: @escaping () -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        let pathForTotal = "/myTrips/\(id)/totalDays"
        
        firebaseManager.updateData(
            path: pathForTotal,
            value: total,
            success: {
                success()
        },
            failure: { (error) in
                
                failure(error)
        })
        
        let pathForEnd = "/myTrips/\(id)/endDate"
        
        firebaseManager.updateData(
            path: pathForEnd,
            value: end,
            success: {
                
                success()
        },
            failure: { (error) in
                
                failure(error)
        })
    }
}
