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
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class ViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var coordinateInput: UITextField!
    var calculatedCoordinates = (lat: Double(0), long: Double(0))
    let coordinatesClass = Coordinates()

    let locationManager: CLLocationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()

    @IBOutlet var openMapsButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var coordinateProgress: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Ask for location authorization
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        applicationDidBecomeActive()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
    }

    @objc func applicationDidBecomeActive() {
        // Show the keyboard
        coordinateInput.becomeFirstResponder()

        pasteInCoordinateInput()
    }

    func pasteInCoordinateInput() {

        // Directly paste if last launch of the app fastforwarded to maps. Even overwrite (normally anyway empty) coordinateInput text. So that at relaunch of the app it makes sense to the user, which coordinates have been used
        let pastedLastTime = UserDefaults.standard.object(forKey: "FFWpastedLastTime") as? Bool ?? false
        if pastedLastTime {
            print("Last time coordinates got fast forwarded. Directly paste them to coordinateInput now")
            let pastedCoordinates = UserDefaults.standard.object(forKey: "FFWpasted") as? String
            coordinateInput.text = pastedCoordinates
            coordinateInputEditingChanged(coordinateInput) // Trigger change
            UserDefaults.standard.removeObject(forKey: "FFWpastedLastTime")
            return
        }

        // Don't overwrite already written coordinateInput text
        if coordinateInput.text != "" {
            return
        }

        // Paste if enabled in settings
        let pasteSetting = UserDefaults.standard.object(forKey: "Paste") as? Bool ?? BooleanSetting.name("Paste").getDefaults()
        if pasteSetting {
            if let pasteString = UIPasteboard.general.string {
                if coordinatesClass.parseCoordinates(coordinates: pasteString).Ey != 0 && coordinatesClass.parseCoordinates(coordinates: pasteString).Nx != 0 { // 0 means invalid coordinates

                    // Animate pasting
                    let middleIndex = pasteString.index(pasteString.startIndex, offsetBy: (pasteString.characters.count / 2))
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        let halfstring = pasteString.prefix(upTo: middleIndex)
                        self.coordinateInput.text = "\(halfstring)"
                        self.bounceTextField(textField: self.coordinateInput, progressView: self.coordinateProgress)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            self.coordinateInput.text = pasteString
                            self.coordinateInputEditingChanged(self.coordinateInput) // Trigger change
                        }
                    }
                }
            }
        }
    }

    func bounceTextField(textField: UITextField, progressView: UIProgressView?) {
        let animation = CAKeyframeAnimation(keyPath: "position.y")
        animation.values = [0, 15, -5, 10, 0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.duration = 0.5
        animation.isAdditive = true
        textField.layer.add(animation, forKey: "shakeAnimation")

        if progressView != nil {
            progressView?.layer.add(animation, forKey: "shakeAnimation")
        }
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
        var lat = Calc1903.CHtoWGSlat(x: Double(coordinates.Nx), y: Double(coordinates.Ey))
        var long = Calc1903.CHtoWGSlong(x: Double(coordinates.Nx), y: Double(coordinates.Ey))

        showPositionOnMaps(lat: lat, long: long, coordinateTitle: String("\(coordinates.Nx)/\(coordinates.Ey)"))
        calculatedCoordinates = (lat: lat, long: long)
        
        // TODO: Enable «Tap to open» now for the first time! Deactivate it, if no valid coordinates!

        if coordinates.LV95 {
            coordinateProgress.setProgress(0.0, animated: false)
            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                self.coordinateProgress.alpha = 1 // Here you will get the animation you want
            })
            
            // Nx can be only 5 numbers, so count the numbers and add a 0 if needed
            var geodesyURL = "https://geodesy.geo.admin.ch/reframe/lv95towgs84?format=json&easting="
            geodesyURL += "2\(coordinates.Ey)&northing="
            if String(coordinates.Nx).characters.count == 5 {
                geodesyURL += "10\(coordinates.Nx)"
            } else {
                geodesyURL += "1\(coordinates.Nx)"
            }

            // Start the request
            // TODO: What if the request fails?
            Alamofire.request(geodesyURL)
                .downloadProgress { progress in
                    // multiply with 0.6 cause otherwise the progress-bar is immediatly 100%
                    // when the request is done it is set to 1.0 with animated, so ther user can see a completion
                    self.coordinateProgress.setProgress(Float(progress.fractionCompleted)*0.6, animated: false)
                }
                .validate(statusCode: 200 ..< 300)
                .validate(contentType: ["application/json"])
                .responseObject { (response: DataResponse<JSONlv95towgs84Response>) in
                    switch response.result {
                    case let .failure(error):
                        debugPrint(error)
                        break
                    case .success(_):
                        let lv95toWGS84Coordinates = response.result.value
                        let easting = lv95toWGS84Coordinates?.easting
                        let northing = lv95toWGS84Coordinates?.northing
                        
                        if easting != nil && northing != nil {
                            lat = Double(northing!)!
                            long = Double(easting!)!
                            debugPrint("Got answer from geo.admin.ch: easting: \(long), northing: \(lat)")
                            self.showPositionOnMaps(lat: lat, long: long, coordinateTitle: String("\(coordinates.Nx)/\(coordinates.Ey)"))
                            self.calculatedCoordinates = (lat: lat, long: long)
                        }
                    }
                    self.coordinateProgress.setProgress(1.0, animated: true)
                    // Hide the progressView shortly after request is done
                    UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
                        self.coordinateProgress.alpha = 0 // because only alpha can be animated, isHidden cannot
                    })
                }
        }
    }

    @IBOutlet var backgroundMap: MKMapView!

    @IBAction func openMapsButtonTriggered(_: Any) {
        openMaps(lat: calculatedCoordinates.lat, long: calculatedCoordinates.long)
    }

    @IBAction func openMapsButtonDidEndOnExit(_: Any) {
        openMaps(lat: calculatedCoordinates.lat, long: calculatedCoordinates.long)
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

    func openMaps(lat: Double, long: Double, clear _: Bool = false) {
        let mapProviderSetting: String = UserDefaults.standard.object(forKey: "savedMapProvider") as? String ?? "Apple"
        let routingSetting = UserDefaults.standard.object(forKey: "Routing") as? Bool ?? BooleanSetting.name("Routing").getDefaults()
        var mapsURLString = String()

        mapsURLString = AvailableMap.getCase(map: mapProviderSetting).urlFormat(lat: lat, long: long, routing: routingSetting)
        let mapsURL = URL(string: mapsURLString)!

        if !UIApplication.shared.openURL(mapsURL) {
            debugPrint("Not possible to open Map")
        }
        // TODO: What happens, if Waze URL is loaded and it isn't installed? => Inform user!

        // TODO: Is this really a good idea? What is, if user entered coordinates, and now copied and used FFW on new (copied) coordinates?
        //        if clear {
        //            coordinateInput.text = ""
        //        }
    }
}
