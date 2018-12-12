//
//  TravelTests.swift
//  TravelTests
//
//  Created by TaiHsinLee on 2018/12/5.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import XCTest
@testable import Travel

class TriplistViewControllerTests: XCTestCase {
    
    var controllerUnderTest: TripListViewController!
    
    let firebaseManager = FirebaseManagerMock()
    
    let decoder = JSONDecoder()
    
    var locations: [Location] = []
    
    var thDatas: [THdata] = []
    
    var result: [[THdata]] = []

    override func setUp() {
        super.setUp()
        
        // Setup SUT
        controllerUnderTest = UIStoryboard(name: "MyTrip", bundle: nil)
            .instantiateViewController(
                withIdentifier: String(
                    describing: TripListViewController.self)
            )
            as? TripListViewController
    }

    // Release SUT
    override func tearDown() {
        
        controllerUnderTest = nil
        
        super.tearDown()
    }
    
    func test_CreateWeekDay_ParseData() {
        
        // Arrange
        let startDate = Double(1543334400)
        let totalDays = 5
        
        // Act
        controllerUnderTest.createWeekDay(startDate: startDate, totalDays: totalDays)
        
        // Assert
        
        let lhsCount = controllerUnderTest.dates.count
        XCTAssertEqual(lhsCount, 5)
    }

    func test_sortLocations_ParsesData() {
        
        // Arrange
        let testBundle = Bundle(for: type(of: self))
        
        let path = testBundle.path(forResource: "abbaData", ofType: "json")
        
        guard let data = try? Data(
            contentsOf: URL(fileURLWithPath: path!),
            options: .alwaysMapped
            ) else {
            return
        }
        
        do {
            
            let testData = try self.decoder.decode([Location].self, from: data)
            
            locations = testData
            
        } catch {
            
            print(error)
        }
        
        for location in locations {
            
            let thDAta = THdata(location: location, type: .location)
            
            thDatas.append(thDAta)
        }
        
        // Act
        
        controllerUnderTest.sortLocations(locations: thDatas, total: 5)
        
        // Assert
        
        let count = controllerUnderTest.dataArray.count
        
        for index in 0 ..< count - 1 {
            
            let firstLhs = controllerUnderTest.dataArray[index][0].location.days
            
            let secondLhs = controllerUnderTest.dataArray[index + 1][0].location.days
            
            XCTAssert(firstLhs < secondLhs)
        }
    }
    
    func test_updateLocalData_updateData() {
        
        // Arrange
        
        var array: [[THdata]] = []
        
        for _ in 1 ... 5 {
            
            let location = Location.randomLocation()
            let thData = THdata(location: location, type: .location)
            
            array.append([thData])
        }
        
        controllerUnderTest.locationArray = array
        
        // Act
        
        controllerUnderTest.updateLocalData()
        
        // Assert
        
        let result = controllerUnderTest.dataArray
        
        XCTAssertEqual(array.count, result.count)
    }
}
