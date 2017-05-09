//
//  MapVC.swift
//  Test - Pane&Design
//
//  Created by Yerlan Ismailov on 09.05.17.
//  Copyright © 2017 Luca Casula. All rights reserved.
//

import UIKit
import MapKit

protocol WeatherLocationDelegate {
    func didSelectLocation(lat: Double, lng: Double)
}

class MapVC: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var delegate: WeatherLocationDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        self.mapView.showsUserLocation = true
        
        
    }
    
    func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        
        if delegate != nil {
            
            for annotation in self.mapView.annotations {
                delegate?.didSelectLocation(lat: annotation.coordinate.latitude, lng: annotation.coordinate.longitude)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    

}
