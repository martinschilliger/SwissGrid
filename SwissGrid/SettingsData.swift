//
//  SettingsData.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 24.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import Foundation
import UIKit

enum SectionFooter {
    static func getText(section: Int) -> String? {
        switch section {
        case 0:
            return "Is your favorite map application missing? Please tell that Martin: info@martin-apps.ch"
        case 1:
            return "FastForward looks for coordinates in the pasteboard and then opens your favorite maps app directly on launch. The LV95 to WGS84 conversion service of geo.admin.ch will not be used."
        default:
            return nil
        }
    }
}

enum BooleanSetting {
    case id(Int)
    case name(String)
    static let availableSettings = ["MapType", "Routing", "Paste", "FFW"]
    static let count = availableSettings.count

    private func findName(_ id: Int) -> String {
        return BooleanSetting.availableSettings[id]
    }

    func getName() -> String {
        var keyName = String()
        switch self {
        case let .id(idGiven):
            keyName = findName(idGiven)
        case let .name(nameGiven):
            keyName = nameGiven
        }
        return keyName
    }

    func getDescription() -> String {
        let keyName = getName()
        let descriptions: [String: String] = [
            "FFW": "FastForward coordinates",
            "Paste": "Auto paste content",
            "MapType": "Force aerial view",
            "Routing": "Start routing directly",
        ]

        return descriptions[keyName]!
    }

    func getDefaults() -> Bool {
        let keyName = getName()
        let defaults: [String: Bool] = [
            "FFW": false,
            "Paste": true,
            "MapType": false,
            "Routing": true,
        ]
        return defaults[keyName]!
    }
}

enum AvailableMap {
    case AppleMaps, GoogleMaps, Waze, MapsMe, OSM, /* TomTom, */ Navigon, Garmin, SBB // => TomTom doesn't have an launchurl right now…

    // Define variables here also, for easier reading in swift
    // be shure to change ViewController.swift openMaps() also!
    // sorting of maps is done here also
    static let maps = ["Apple", "Google", "maps.me", "Waze", "OpenStreetMap", /* "TomTom", */ "Navigon", "Garmin Western Europe", "SBB Mobile"]
    static let count = maps.count

    static func getCase(map: String) -> AvailableMap {
        switch map {
        case "Apple":
            return AvailableMap.AppleMaps
        case "Google":
            return AvailableMap.GoogleMaps
        case "maps.me":
            return AvailableMap.MapsMe
        case "Waze":
            return AvailableMap.Waze
        case "OpenStreetMap":
            return AvailableMap.OSM
            //        case "TomTom":
            //            return AvailableMap.TomTom
        case "Navigon":
            return AvailableMap.Navigon
        case "Garmin Western Europe":
            return AvailableMap.Garmin
        case "SBB Mobile":
            return AvailableMap.SBB
        default:
            return AvailableMap.AppleMaps
        }
    }

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
        case .SBB:
            return "SBB Mobile"
        }
    }

    func urlBase(test: Bool = false) -> String {
        var url: String
        // Define URL of provider => Be shure to add them to the Info.plist also!
        
        switch self {
        case .AppleMaps:
            url = "https://maps.apple.com"
            break
        case .GoogleMaps:
            if /* test || */ UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) { // => google maps web app should always be available
                url = "comgooglemaps://"
            } else {
                url = "https://maps.google.com"
            }
            break
        case .Waze:
            if test || UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
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
        case .SBB:
            // Got information here: https://www.sbb.ch/content/dam/sbb/en/pdf/en_mobile/SBBmobile_Developer.pdf
            url = "sbbmobile://"
            break
        }

        return url
    }

    func urlFormat(lat: Double, long: Double, routing: Bool) -> String {
        func roundDouble(_ double: Double, _ decimals: Int = 5) -> Double {
            var rounded: Double
            let exponent = pow(Double(10), Double(decimals))
            rounded = Double(double) * exponent
            rounded = round(rounded)
            rounded = rounded / exponent

            return rounded
        }

        var url: String = urlBase()
        let lat = roundDouble(lat)
        let long = roundDouble(long)

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
                url += "?ll=\(lat),\(long)"
            } else {
                url += "?ll=\(lat),\(long)&navigate=yes"
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
                url += "gm?action=map&lat=\(lat)&lon=\(long)"
            } else {
                url += "gm?action=nav&lat=\(lat)&lon=\(long)"
            }
            break
        case .SBB:
            url += "timetable?toll=\(lat),\(long)"
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
            case .Waze, .MapsMe, .OSM, /* .TomTom, */ .Navigon, .Garmin, .SBB:
                // no satellite map possible
                break
            }
        }

        // return the complete URL
        return url
    }
}
