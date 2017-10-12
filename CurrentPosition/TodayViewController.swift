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

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet var currentPosition: UILabel!
    // This is used to indicate whether an update of the today widget is required or not
    private var updateResult = NCUpdateResult.noData

    // We use a lazy instance of CLLocationManager to get the user's location
    private lazy var locman = CLLocationManager()

    let Calc1903 = CLLocation1903()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.

        locman.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        locman.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        currentPosition.text = "\(formatter.string(for: y)!)/\(formatter.string(for: x)!)"
    }
}

typealias LocationDelegate = TodayViewController
extension LocationDelegate: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        // If we could not retrive location data, set our update result to Failed
        updateResult = .failed
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Do stuff with the retrieved location, update our display and then set our update result to NewData
        updateDisplay(location: locations.first!)
        updateResult = .newData
    }
}
