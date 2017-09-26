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
    let coordinatesClass = Coordinates()
    
    @IBOutlet var openMapsButton: UIButton!
    @IBOutlet var settingsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Show the keyboard
        coordinateInput.becomeFirstResponder()

        // Paste if enabled in settings
        let pasteSetting = UserDefaults.standard.object(forKey: "Paste") as? Bool ?? BooleanSetting.name("Paste").getDefaults()
        if pasteSetting {
            if let pasteString = UIPasteboard.general.string {
                if coordinatesClass.parseCoordinates(coordinates: pasteString).Ey != 0 && coordinatesClass.parseCoordinates(coordinates: pasteString).Nx != 0 { // 0 means invalid coordinates
                    // Animate pasting
                    let middleIndex = pasteString.index(pasteString.startIndex, offsetBy: (pasteString.characters.count / 2))
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        let halfstring = pasteString.prefix(upTo: middleIndex)
                        self.coordinateInput.text = "\(halfstring)"
                        self.bounceTextField(textField: self.coordinateInput)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                            self.coordinateInput.text = pasteString
                            self.coordinateInputEditingChanged(self.coordinateInput) // Trigger change
                        }
                    }
                    
                }
            }
        }
    }
    
    func bounceTextField(textField: UITextField) {
        let animation = CAKeyframeAnimation(keyPath: "position.y")
        animation.values = [0,15,-5,10,0]
        animation.keyTimes = [0,0.25,0.5,0.75,1]
        animation.duration = 0.5
        animation.isAdditive = true
        textField.layer.add(animation, forKey: "shakeAnimation")
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Coordinates got typed
    @IBAction func coordinateInputEditingChanged(_ sender: UITextField) {
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
        // TODO: Enable «Tap to open» now for the first time! Deactivate it, if no valid coordinates!
    }

    @IBOutlet var backgroundMap: MKMapView!
    
    @IBAction func openMapsButtonTriggered(_ sender: Any) {
        openMaps()
    }
    @IBAction func openMapsButtonDidEndOnExit(_ sender: Any) {
        openMaps()
    }
    
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
    
    func openMaps() {
        let mapProviderSetting:String = UserDefaults.standard.object(forKey: "savedMapProvider") as? String ?? "Apple"
        let routingSetting = UserDefaults.standard.object(forKey: "Routing") as? Bool ?? BooleanSetting.name("Routing").getDefaults()
        var mapsURLString = String()
        
        // TODO: Round Double coordinates to useful size
        
        switch mapProviderSetting {
        case "Google":
            mapsURLString = AvailableMap.GoogleMaps.urlFormat(lat: calculatedCoordinates.lat, long: calculatedCoordinates.long, routing: routingSetting)
            break
        case "Waze":
            mapsURLString = AvailableMap.Waze.urlFormat(lat: calculatedCoordinates.lat, long: calculatedCoordinates.long, routing: routingSetting)
            break
        case "maps.me":
            mapsURLString = AvailableMap.MapsMe.urlFormat(lat: calculatedCoordinates.lat, long: calculatedCoordinates.long, routing: routingSetting)
            break
        case "OpenStreetMap":
            mapsURLString = AvailableMap.OSM.urlFormat(lat: calculatedCoordinates.lat, long: calculatedCoordinates.long, routing: routingSetting)
            break
//        case "TomTom":
//            mapsURLString = AvailableMap.TomTom.urlFormat(lat: calculatedCoordinates.lat, long: calculatedCoordinates.long, routing: routing)
//            break
        case "Navigon":
            mapsURLString = AvailableMap.Navigon.urlFormat(lat: calculatedCoordinates.lat, long: calculatedCoordinates.long, routing: routingSetting)
            break
        case "Garmin Western Europe":
            mapsURLString = AvailableMap.Garmin.urlFormat(lat: calculatedCoordinates.lat, long: calculatedCoordinates.long, routing: routingSetting)
            break
        default: // case "Apple"
            mapsURLString = AvailableMap.AppleMaps.urlFormat(lat: calculatedCoordinates.lat, long: calculatedCoordinates.long, routing: routingSetting)
        }
        let mapsURL = URL(string: mapsURLString)!
        
        if !UIApplication.shared.openURL(mapsURL) {
            debugPrint("Not possible to open Map")
        }
        //TODO: What happens, if Waze URL is loaded and it isn't installed?
    }
    
}
