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
    
    func loadFirstPhotoForPlace(placeID: String, success: @escaping (UIImage) -> Void) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto, success: { (photo) in
                        
                        success(photo)
                    })
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, success: @escaping (UIImage) -> Void) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: { (photo, error)
            -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                guard let photo = photo else { return }
                success(photo)
                //  self.imageView.image = photo;
                //  self.attributionTextView.attributedText = photoMetadata.attributions;
            }
        })
    }
}
