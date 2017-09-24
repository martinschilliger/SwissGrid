//
//  SettingsData.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 24.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import Foundation
import UIKit

enum AvailableMaps {
    case AppleMaps, GoogleMaps, Waze
    
    func urlFormat(lat: Double, long: Double, routing: Bool) -> String {
        var url:String;

        // Define URL of provider
        switch (self) {
        case .AppleMaps:
            url = "https://maps.apple.com"
            break;
        case .GoogleMaps:
            if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                url = "comgooglemaps://"
            } else {
                url = "https://maps.google.com"
            }
            break
        case .Waze:
            url = "waze://"
        }
        
        // Define URL content
        switch (self) {
        case .AppleMaps:
            if !routing {
                url += "?q=\(lat),\(long)"
            } else {
                url += "?saddr=&daddr=\(lat),\(long)"
            }
        case .GoogleMaps:
            if !routing {
                url += "?q=loc:\(lat),\(long)"
            } else {
                url += "?saddr=&daddr=\(lat),\(long)"
            }
        case .Waze:
            if !routing {
                url +=  "?ll=\(lat),\(long)"
            } else {
                url +=  "?ll=\(lat),\(long)&navigate=yes"
            }
            
        }
        
        // return the complete URL
        return url;
    }
}


