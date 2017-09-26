//
//  SettingsData.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 24.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import Foundation
import UIKit

enum BooleanSetting {
    case id(Int)
    case name(String)
    static let availableSettings = ["FFW", "Paste", "MapType", "Routing"]
    static let count = availableSettings.count
    
    private func findName(_ id: Int) -> String {
        return BooleanSetting.availableSettings[id];
    }
    
    func getName() -> String {
        var keyName = String()
        switch self {
        case .id(let idGiven):
            keyName = findName(idGiven)
        case .name(let nameGiven):
            keyName = nameGiven
        }
        return keyName
    }
    
    func getDescription() -> String {
        let keyName = getName()
        let descriptions:[String:String] = [
            "FFW" : "FastForward coordinates",
            "Paste" : "Auto paste content",
            "MapType" : "Force Aerial view",
            "Routing" : "Start routing directly",
            ];
        
        return descriptions[keyName]!
    }
    
    func getDefaults() -> Bool {
        let keyName = getName()
        let defaults:[String:Bool] = [
            "FFW" : false,
            "Paste" : true,
            "MapType" : false,
            "Routing" : true,
            ];
        return defaults[keyName]!
    }
}
    
    


enum AvailableMap {
    case AppleMaps, GoogleMaps, Waze, MapsMe, OSM, /*TomTom, */Navigon, Garmin
    
    // Define variables here also, for easier reading in swift
    // be shure to change ViewController.swift openMaps() also!
    // sorting of maps is done here also
    static let maps = ["Apple", "Google", "maps.me", "Waze", "OpenStreetMap", /*"TomTom", */"Navigon", "Garmin Western Europe"];
    static let count = maps.count
    
    func getDescription() -> String {
        switch self {
        case .AppleMaps:
            return "Apple"
        case .GoogleMaps:
            return "Google"
        case .Waze:
            return "Waze"
        case .MapsMe:
            return "maps.me"
        case .OSM:
            return "OpenStreetMap"
//        case .TomTom:
//            return "TomTom"
        case .Navigon:
            return "Navigon"
        case .Garmin:
            return "Garmin Western Europe"
        }
    }
    
    func urlFormat(lat: Double, long: Double, routing: Bool) -> String {
        var url:String;

        // Define URL of provider
        switch self {
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
            if UIApplication.shared.canOpenURL(URL(string:"waze://")!) {
                url = "waze://"
            } else {
                url = "https://waze.com/ul"
            }
            break
        case .MapsMe:
            url = "mapswithme://"
            break
        case .OSM:
            url = "http://www.openstreetmap.org"
            break
//        case .TomTom:
//            url = "tomtomhome://"
//            break
        case .Navigon:
            url = "navigon://"
            break
        case .Garmin:
            url = "garminonboardwesterneurope://"
            break
        }
        
        // Define URL content
        switch self {
        case .AppleMaps:
            if !routing {
                url += "?q=\(lat),\(long)"
            } else {
                url += "?saddr=&daddr=\(lat),\(long)"
            }
            break
        case .GoogleMaps:
            if !routing {
                url += "?q=loc:\(lat),\(long)"
            } else {
                url += "?saddr=&daddr=\(lat),\(long)"
            }
            break
        case .Waze:
            if !routing {
                url +=  "?ll=\(lat),\(long)"
            } else {
                url +=  "?ll=\(lat),\(long)&navigate=yes"
            }
            break
        case .MapsMe:
            url += "map?v=1&ll=\(lat),\(long)"
            break
        case .OSM:
            url += "?mlat=\(lat)&mlon=\(long)"
            break
//        case .TomTom:
//            url += "geo:action=show&lat=\(lat)&long=\(long)"
//            break
        case .Navigon:
            url += "coordinate/SwissGrid/\(long)/\(lat)"
            break
        case .Garmin:
            if !routing {
                url +=  "gm?action=map&lat=\(lat)&lon=\(long)"
            } else {
                url +=  "gm?action=nav&lat=\(lat)&lon=\(long)"
            }
            break
        }
        
        // add aerial view if possible
        let mapTypeAerial = UserDefaults.standard.object(forKey: "MapType") as? Bool ?? BooleanSetting.name("MapType").getDefaults()
        if mapTypeAerial {
            switch self {
            case .AppleMaps:
                url += "&t=h"
                break
            case .GoogleMaps:
                url += "&views=satellite"
                break
            case .Waze, .MapsMe, .OSM, /*.TomTom, */.Navigon, .Garmin:
                // no satellite map possible
                break
            }
        }
        
        // return the complete URL
        return url;
    }
}


