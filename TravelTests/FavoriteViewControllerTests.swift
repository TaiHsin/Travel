//
//  FavoriteViewControllerTests.swift
//  TravelTests
//
//  Created by TaiHsinLee on 2018/12/10.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import XCTest
@testable import Travel

class FavoriteViewControllerTests: XCTestCase {

    var controllerUnderTest: FavoriteViewController!
    
    override func setUp() {
        
        controllerUnderTest = UIStoryboard(name: "Favorite", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: FavoriteViewController.self))
            as? FavoriteViewController
        
        controllerUnderTest.thDataManager = THDataManager(firebaseManager: FirebaseManagerMock())
    }

    override func tearDown() {
        
        controllerUnderTest = nil
        
        super.tearDown()
    }

    func test_removeFavorite_deleteData() {
        
        // Arrange
        
        let locationID = "Test location id"
        
        // Act
        
        controllerUnderTest.removeFavorite(locationID: locationID)
        
        // Assert
         
    }
}
