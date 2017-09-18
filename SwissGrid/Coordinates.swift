//
//  Coordinates.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 18.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import Foundation
import UIKit

class Coordinates {

    // Parse the String from the coordinateInput and make Ints from it
    func parseCoordinates(coordinates: String) -> (E: Int, N: Int, LV95: Bool) {

        // Replace everything but numbers
        let regexOnlyNumbers = try! NSRegularExpression(pattern: "([\\D])", options: NSRegularExpression.Options.caseInsensitive)
        let regexRange = NSMakeRange(0, coordinates.characters.count)
        let coordinatesOnlyNumbers = regexOnlyNumbers.stringByReplacingMatches(in: coordinates, options: [], range: regexRange, withTemplate: "")

        //        print("Only Numbers: \(coordinatesOnlyNumbers)");

        if checkCoordinatesValidity(coordinates: coordinatesOnlyNumbers) {
            print("Coordinates \(coordinatesOnlyNumbers) are valid")
        } else {
            print("Coordinates \(coordinatesOnlyNumbers) are invalid")
        }

        var E: Int
        var N: Int
        var LV95: Bool

        E = 2_600_000
        N = 1_200_000
        LV95 = true

        return (E, N, LV95)
    }

    func checkCoordinatesValidity(coordinates: String) -> Bool {
        var coordinate1 = String()
        var coordinate2 = String()
        var coordinate1Type = String()
        var coordinate2Type = String()

        // Only even numbers can be a valid coordinates-pair
        if coordinates.characters.count % 2 != 0 {
            return false
        }

        // Find out the type of coordinates
        coordinate1 = coordinates.substring(to: coordinates.index(coordinates.startIndex, offsetBy: (coordinates.characters.count / 2)))
        coordinate2 = coordinates.substring(from: coordinates.index(coordinates.startIndex, offsetBy: (coordinates.characters.count / 2)))
        //        print("coordinate  1: \(coordinate1), coordinate 2: \(coordinate2)")
        coordinate1Type = findCoordinateType(coordinate: coordinate1)
        coordinate2Type = findCoordinateType(coordinate: coordinate2)

        if !(coordinate1Type != "invalid" && coordinate2Type != "invalid") {
            return false
        }

        return true
    }

    func findCoordinateType(coordinate: String) -> String {
        var coordinateType = String()

        switch coordinate.characters.count {
        case 6:
            // Must be a simple LV03 coordinate

            coordinateType = "LV03"
            break

        case 7:
            // Must be a simple LV95 coordinate or a LV03 with one leading zero

            coordinateType = "LV95"
            break

        case 8:
            // Must be a LV03 coordinate with two leading zeros or a LV95 cooridnate with one leading zero

            coordinateType = "LV95-0"
            break

        case 9:
            // Must be a LV95 coordinate with two leading zeros

            coordinateType = "LV95-00"
            break
        default:
            coordinateType = "invalid"
        }

        return coordinateType
    }
}
