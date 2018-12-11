//
//  FirebaseManagerMock.swift
//  TravelTests
//
//  Created by TaiHsinLee on 2018/12/10.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation
@testable import Travel

class FirebaseManagerMock: FirebaseProtocol {
    
    var dataDict: [String: Location]? = [:]
    
    var key = "test key"
    
    var failureFlag = false
    
    func fetchData(
        path: String,
        success: @escaping (Any?) -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        if failureFlag == true {
            
            failure(TravelError.serverError)
        } else {
            
            success(dataDict)
        }
    }
    
    func fetchDataWithQuery(
        path: String,
        child: String,
        value: Any?,
        success: @escaping (Any?) -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        if failureFlag == false {
            
            success(dataDict)
        } else {
            
            failure(TravelError.serverError)
        }
    }
    
    func updateData(
        path: String,
        value: Any,
        success: @escaping () -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        success()
    }
    
    func deleteData(
        path: String,
        success: @escaping () -> Void,
        failure: @escaping (TravelError) -> Void
        ) {
        
        if failureFlag == false {
            
            success()
        } else {
            
            failure(TravelError.serverError)
        }
    }
    
    func createAutoKey(path: String) -> String {
        
        self.key = path
        
        return key
    }
}
