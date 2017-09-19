//
//  ViewController.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 14.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var coordinateInput: UITextField!

    @IBOutlet var MapShadow: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Set Delegate for function
        //        coordinateInput.delegate = self;

        coordinateInput.text = "600'000/200'000"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Coordinates got typed
    @IBAction func coordinateInputEditingChanged(_ sender: UITextField) {
        //        print("Changed value: \(sender.text ?? "")");
        var coordinatesClass = Coordinates()

        coordinatesClass.parseCoordinates(coordinates: sender.text!)
    }
}
