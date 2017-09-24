//
//  ViewController.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 14.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var coordinateInput: UITextField!
    var calculatedCoordinates = (lat:Double(0), long: Double(0))
    
    @IBOutlet var openMapsButton: UIButton!
    @IBOutlet var settingsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        coordinateInput.becomeFirstResponder()

        // TODO: Remove the prefill
        // Just for developement
        coordinateInput.text = "1 087 648/2 722 759"
        coordinateInput.text = "600 000 / 200 000"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Coordinates got typed
    @IBAction func coordinateInputEditingChanged(_ sender: UITextField) {
        //        print("Changed value: \(sender.text ?? "")");
        let coordinatesClass = Coordinates()
        let coordinates = coordinatesClass.parseCoordinates(coordinates: sender.text!)

        debugPrint(coordinates)

        if coordinates.Ey == 0 || coordinates.Nx == 0 {
            return
        }

        let Calc1903 = CLLocation1903()
        let lat = Calc1903.CHtoWGSlat(x: Double(coordinates.Nx), y: Double(coordinates.Ey))
        let long = Calc1903.CHtoWGSlong(x: Double(coordinates.Nx), y: Double(coordinates.Ey))

        showPositionOnMaps(lat: lat, long: long, coordinateTitle: String("\(coordinates.Nx)/\(coordinates.Ey)"))
        
        calculatedCoordinates = (lat: lat, long: long)
    }

    @IBOutlet var backgroundMap: MKMapView!

    func showPositionOnMaps(lat: Double, long: Double, coordinateTitle: String) {

        // remove the old marker
        backgroundMap.removeAnnotations(backgroundMap.annotations)

        let lat: CLLocationDegrees = lat
        let long: CLLocationDegrees = long

        // visible radius, kinda zoom level
        let latDelta: CLLocationDegrees = 0.03
        let longDelta: CLLocationDegrees = 0.03
        let theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)

        let mypos: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)

        let myreg: MKCoordinateRegion = MKCoordinateRegionMake(mypos, theSpan)
        backgroundMap.setRegion(myreg, animated: true)

        let myposannot = MKPointAnnotation()
        myposannot.coordinate = mypos
        myposannot.title = coordinateTitle

        backgroundMap.addAnnotation(myposannot)
    }
    @IBAction func openMapsButtonTriggered(_ sender: Any) {
        let mapsURL = URL(string: AvailableMaps.GoogleMaps.urlFormat(lat: calculatedCoordinates.lat, long: calculatedCoordinates.long, routing: false))!
        UIApplication.shared.openURL(mapsURL)
        //TODO: What happens, if Waze URL is loaded and it isn't installed?
    }
}
