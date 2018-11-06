//
//  MapViewController.swift
//  Travel
//
//  Created by TaiShin on 2018/10/31.
//  Copyright © 2018年 TaiHsinLee. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol ShowListDelegate: AnyObject {
    
    func didShowListHit()
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var showListButton: UIButton!
    
    private let locationManager = CLLocationManager()
    
    weak var delegate: ShowListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        showListButton.isHidden = true
    }
    
    func setupMapView() {
        
        mapView.delegate = self
        
        let padding = showListButton.frame.height
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: padding, right: 0)
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func backToList(_ sender: UIButton) {
        
        showListButton.isHidden = true
        delegate?.didShowListHit()
    }
    
    func getCurrentLocation() {
        
        locationManager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func showMarker(locations: [Location]) {
        
        var bounds = GMSCoordinateBounds()
        
        for data in locations {
            
            let latitude = data.latitude
            let longitude = data.longitude
            
            let position = CLLocationCoordinate2DMake(latitude, longitude)
            let marker = GMSMarker(position: position)
            
            let markerImage = UIImage(named: Constants.locationIcon)
            let markerView = UIImageView(image: markerImage)
            markerView.tintColor = UIColor.battleshipGrey
            marker.iconView = markerView
            marker.title = data.name
            marker.map = mapView
            
            mapView.setMinZoom(5, maxZoom: 15)
            
            let bottomHeight = mapView.frame.size.height - 260
            let edgeInsets = UIEdgeInsets(
                top: 80,
                left: 50,
                bottom: bottomHeight,
                right: 50
            )
            
            bounds = bounds.includingCoordinate(marker.position)
            mapView.animate(with: .fit(bounds, with: edgeInsets))
        }
    }
}

// MARK: - GMS Map View Delegate

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return false
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    // didChangeAuthorization function is called when the user grants or revokes location permissions.
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse else { return }
        
        getCurrentLocation()
    }
}
