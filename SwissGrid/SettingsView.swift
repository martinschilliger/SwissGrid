//
//  SettingsView.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 20.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import Foundation
import UIKit

// add this custom initializer; You need to do this as soon as the controlled is initialized – if you wait until viewDidLoad() the animation goes awry. 
// => https://www.hackingwithswift.com/articles/5/how-to-adopt-ios-11-user-interface-changes-in-your-app
//required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//    navigationItem.largeTitleDisplayMode = .never
//}

class SettingsViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Makes the title large (iOS11) => https://stackoverflow.com/a/44410330/1145706
        //navigationController?.navigationBar.prefersLargeTitles = true
        // or
//        if #available(iOS 11.0, *) {
//            self.navigationController?.navigationBar.prefersLargeTitles = true
//            self.navigationItem.largeTitleDisplayMode = .always
//        } else {
//            // Fallback on earlier versions
//        }
        
    }
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBAction func closeButtonTriggered(_ sender: Any) {
                navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
