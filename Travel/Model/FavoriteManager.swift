//
//  FavoriteManager.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/12/8.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation
import KeychainAccess

class FavoriteManager {
    
    private let firebaseManager = FirebaseManager()
    
    private let decoder = JSONDecoder()
    
    private let keychain = Keychain(service: "com.TaiHsinLee.Travel")
    
    func fetchFavoritelist(
        success: @escaping ([Location]) -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        var locations: [Location] = []
        
        guard let uid = keychain["userId"] else {
            
            NotificationCenter.default.post(name: .noData, object: nil)
            
            return
        }
        
        let path = "/favorite/\(uid)"
        
        firebaseManager.fetchData(
            path: path,
            success: { [weak self] (value) in
                
                guard let value = value as? NSDictionary else {
                    
                    NotificationCenter.default.post(name: .noData, object: nil)
                    
                    return
                }
                
                for value in value.allValues {
                    
                    // Data convert: can be refact out independently
                    
                    guard let jsonData = try?  JSONSerialization.data(withJSONObject: value) else {
                        
                        return
                    }
                    
                    do {
                        guard let data = try self?.decoder.decode(Location.self, from: jsonData) else { return }
                        
                        locations.append(data)
                        
                    } catch {
                        
                        failure(TravelError.decodeError)
                    }
                }
                success(locations)
            },
            failure: { (error) in
                
                failure(error)
        })
    }
}
