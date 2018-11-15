//
//  PhotoProvider.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/10/9.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import Foundation
import GooglePlaces

// Get Google place photo from placeID

class PhotoManager {
    
    func loadFirstPhotoForPlace(
        placeID: String,
        success: @escaping (UIImage) -> Void,
        failure: @escaping (Error) -> Void
        ) {
        
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { [weak self] (photos, error) -> Void in
            
            if let error = error {
                
                // TODO: handle the error.
                
                print("Error: \(error.localizedDescription)")
            } else {
                
                if let firstPhoto = photos?.results.first {
                    
                    self?.loadImageForMetadata(
                        photoMetadata: firstPhoto,
                        success: { (photo) in
                        
                        success(photo)
                            
                    }, failure: { (error) in
                        
                        failure(error)
                    })
                }
            }
        }
    }
    
    func loadImageForMetadata(
        photoMetadata: GMSPlacePhotoMetadata,
        success: @escaping (UIImage) -> Void,
        failure: @escaping (Error) -> Void
        ) {
        GMSPlacesClient.shared().loadPlacePhoto(
            photoMetadata, callback: { [weak self] (photo, error)
            -> Void in
            
                if let error = error {
                
                    failure(error)
                
                    print("Error: \(error.localizedDescription)")
                } else {
                
                    guard let photo = photo else {
                        
                        return
                    }

                    success(photo)
            }
        })
    }
}
