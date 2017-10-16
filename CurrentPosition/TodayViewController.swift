//
//  TodayViewController.swift
//  CurrentPosition
//
//  Created by Martin Schilliger on 12.10.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation
import MapKit

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet var currentPosition: UIButton!
    @IBOutlet var currentPositionMap: UIImageView!
    @IBOutlet var copiedLabel: UILabel!
    var currentPositionText = "Location not allowed"
    var memorySaver: Bool = false
    
    // This is used to indicate whether an update of the today widget is required or not
    private var updateResult = NCUpdateResult.noData //TODO: Is this ever getting used?

    // We use a lazy instance of CLLocationManager to get the user's location
    private lazy var locman = CLLocationManager()

    let Calc1903 = CLLocation1903()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.

        locman.delegate = self
        locman.distanceFilter = 10
        locman.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        debugPrint("Memory-Warning!")
        memorySaver = true
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.newData)
    }

    // Update our display
    // TODO: What happens, when location services are not allowed?
    func updateDisplay(location: CLLocation) {
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude

        let x = Int(Calc1903.WGStoCHx(lat: lat, lng: long))
        let y = Int(Calc1903.WGStoCHy(lat: lat, lng: long))

        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        currentPosition.setTitle("\(formatter.string(for: y)!)/\(formatter.string(for: x)!)", for: .normal)
        currentPositionText = "\(y)/\(x)"
        
        // show the map
        if !memorySaver {
            createMapShot(coordinate: location.coordinate)
        }
    }

    @IBAction func locationClicked(_ sender: Any) {
        UIPasteboard.general.string = currentPositionText
        debugPrint("Coordinates copied: \(UIPasteboard.general.string!)")

        // Prevent FFW on Swiss Grid launch
        let pasteffw = UIPasteboard.init(name: UIPasteboardName.init(rawValue: "com.schilliger.swissgrid.ffw"), create: true)
        pasteffw?.string = currentPositionText
        
        copiedLabel.alpha = 1
        UIView.animate(withDuration: 0.3, delay: 2, options: [], animations: {
            self.copiedLabel.alpha = 0
        })
    }
    
    
    // MKMapSnapshot
    func createMapShot(coordinate: CLLocationCoordinate2D) {
        let options = MKMapSnapshotOptions()
        let myreg: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.01, 0.01))
        options.region = myreg
        options.size = currentPositionMap.frame.size

        // Start the snapshotter
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start() {
            snapshot, error in
            
            if error != nil {
                return
            }
            
            self.showMapShot(mapImage: snapshot?.image)
        }
        
    }
    
    func showMapShot(mapImage: UIImage?) {
        if mapImage != nil {
            currentPositionMap.image = mapImage!
            return
        }
        debugPrint("Could not generate a background-Image")
    }
}

typealias LocationDelegate = TodayViewController
extension LocationDelegate: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        // If we could not retrive location data, set our update result to Failed
        updateResult = .failed
        currentPosition.setTitle(currentPositionText, for: .normal)
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Do stuff with the retrieved location, update our display and then set our update result to NewData
        updateDisplay(location: locations.first!)
        updateResult = .newData
    }
}



