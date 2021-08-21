//
//  MapViewExtensions.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 03/06/21.
//

import Foundation
import MapKit

extension MKMapView{
    func centerLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 500){
        let coordinateREgion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateREgion, animated: true)
    }
}
