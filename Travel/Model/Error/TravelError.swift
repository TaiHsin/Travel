//
//  TravelError.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/3.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation

enum TravelError: String, Error {
    
    case loginFacebookFail = "Login with facebook fail"
    
    case loginFacebookReject = "Please permit the facebook login as Travel login"
    
    case decodeError = "Data decode error"
    
    case serverError = "Travel client error"
    
    case fetchError = "Fetch data error"
}
