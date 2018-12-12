//
//  THDataManagerTests.swift
//  TravelTests
//
//  Created by TaiHsinLee on 2018/12/9.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import XCTest
@testable import Travel

class THDataManagerTests: XCTestCase {
    
    let firebaseManager = FirebaseManagerMock()

    var managerUnderTest: THDataManager!
    
    override func setUp() {
        super.setUp()
        
        managerUnderTest = THDataManager(firebaseManager: firebaseManager)
    }

    override func tearDown() {
        
        managerUnderTest = nil
        
        super.tearDown()
    }

    func test_fetchLocations_fetchData() {
        
        // Arrange
        
        let promise = expectation(description: "Data error")
        
        let daysKey = "daysKey" // Dummy
        
        let days = 5 // Dummy
        
        var dict: [String: Location] = [:]
        
        var count = 0
        
        for index in 1 ... 5 {
            
            let location = Location.emptyLocation()
            
            dict[String(index)] = location
        }
        
        firebaseManager.dataDict = dict
        
        // Act
        
        XCTAssertEqual(count, 0, "count should be 0 before fetchLocations")
        
        managerUnderTest.fetchLocations(
            daysKey: daysKey,
            index: days,
            success: { (number) in
                
                count = number
                promise.fulfill()
        },
            failure: { (_) in
                
        })
        
        // Assert
        
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertEqual(count, 5, "Didn't fetch 5 datas from fake response")
    }
    
    func test_checkFavoritelist_fetchNoData() {
     
        // Arrange
        
        let location = Location.emptyLocation()
        
        let promise = expectation(description: "Data error")
        
        firebaseManager.dataDict = nil
        
        // Act
        
        managerUnderTest.checkFavoritelist(
            location: location,
            success: {
                
                promise.fulfill()
        },
            failure: { (_) in

        })
        
        // Assert
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func test_updateLocation_updateData() {
        
        // Arrange
        
        let promise = expectation(description: "Data error")
        
        let daysKey = "daysKey"
        
        let days = 5
        
        let location = Location.emptyLocation()
        
        // Act
        
        managerUnderTest.updateLocation(
            daysKey: daysKey,
            days: days,
            location: location,
            success: {
                
                promise.fulfill()
        },
            failure: { (_) in
                
        })
        
        // Assert
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func test_updateFavorite_updateData() {
        
        // Arrange
        
        let promise = expectation(description: "Data error")
        
        let location = Location.emptyLocation()
        
        // Act
        
        managerUnderTest.updateFavorite(
            location: location,
            success: {
                
                promise.fulfill()
        },
            failure: { (_) in
                
        })
        
        // Assert
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func test_deleteFavorite_deleteData() {
        
        // Arrange
        
        let key = "deleteKey"
        
        let promise = expectation(description: "Data error")
        
        // Act
        
        managerUnderTest.deleteFavorite(
            key: key,
            success: {
                promise.fulfill()
        },
            failure: { (_) in
                
        })
        
        // Assert
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func test_fetchFavoriteKey_fetchData() {
        
        // Arrange
        
        let promise = expectation(description: "Fetch key data")
        
        let locationID = "TestID"
        
        var key = ""
        
        var dict: [String: Location] = [:]
        
        for index in 1 ... 5 {
            
            let location = Location.emptyLocation()
            
            dict[String(index)] = location
        }
        
        firebaseManager.dataDict = dict
        
        // Act
        
        managerUnderTest.fetchFavoriteKey(
            locationID: locationID,
            success: { (data) in
                
                key = data
                promise.fulfill()
        },
            failure: { (_) in
                
        })
        
        // Assert
        
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertTrue(key != "")
    }
    
    func test_updateTriplist_updateData() {
        
        // Arrange
        
        let daysKey = "Test dayskey"
        
        let total = 5
        
        let flag = true
        
        var array: [[THdata]] = []
        
        for _ in 1 ... 5 {
            
            let location = Location.randomLocation()
            let thData = THdata(location: location, type: .location)
            
            array.append([thData])
        }
        
        // Act
        
        managerUnderTest.updateTriplist(
            daysKey: daysKey,
            total: total,
            thDatas: array,
            success: {
                
                XCTAssertTrue(flag)
        },
            failure: { (_) in
                
                XCTFail("Update failed")
        })
        
        // Assert
    }
}
