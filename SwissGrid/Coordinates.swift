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

        // Only even numbers can be a valid coordinates-pair
        if coordinates.characters.count % 2 != 0 {
            return false
        }

        // Find out the type of coordinates
        coordinate1 = coordinates.substring(to: coordinates.index(coordinates.startIndex, offsetBy: (coordinates.characters.count / 2)))
        coordinate2 = coordinates.substring(from: coordinates.index(coordinates.startIndex, offsetBy: (coordinates.characters.count / 2)))
        //        print("coordinate  1: \(coordinate1), coordinate 2: \(coordinate2)")
        let coordinate1Type = findCoordinateType(coordinate: coordinate1)
        let coordinate2Type = findCoordinateType(coordinate: coordinate2)

        if !(coordinate1Type.invalid && coordinate2Type.invalid) && coordinate1Type.coordinateSystem == coordinate2Type.coordinateSystem {
            return false
        }

        return true
    }

    func findCoordinateType(coordinate: String) -> (coordinateType: String, coordinateSystem: String, invalid: Bool) {
        var coordinateType = String()
        var coordinateSystem = String()
        var invalid = Bool()

        // Find number at position and convert to int for further evaluating
        let firstChar = Int("\(coordinate[coordinate.startIndex])")!
        let secondChar = Int("\(coordinate[coordinate.index(coordinate.startIndex, offsetBy: 1)])")!
        let secondLastChar = Int("\(coordinate[coordinate.index(coordinate.endIndex, offsetBy: -2)])")!
        let lastChar = Int("\(coordinate[coordinate.index(coordinate.endIndex, offsetBy: -1)])")!

        debugPrint("firstChar", firstChar)
        debugPrint("secondChar", secondChar)
        debugPrint("secondLastChar", secondLastChar)
        debugPrint("lastChar", lastChar)

        switch coordinate.characters.count {
        case 6:
            // Must be a simple LV03 coordinate

            if firstChar < 4 {
                coordinateType = "LV03x"
                coordinateSystem = "LV03"
            } else {
                coordinateType = "LV03y"
                coordinateSystem = "LV03"
            }

            break

        case 7:
            // Must be a simple LV95 coordinate or a LV03 with one leading zero

            if firstChar == 1 && secondChar < 4 {
                coordinateType = "LV95N"
                coordinateSystem = "LV95"
            } else if firstChar == 2 && secondChar > 4 {
                coordinateType = "LV95E"
                coordinateSystem = "LV95"
            } else if firstChar < 4 && lastChar == 0 {
                coordinateType = "LV03x-0"
                coordinateSystem = "LV03"
            } else if firstChar > 4 && lastChar == 0 {
                coordinateType = "LV03y-0"
                coordinateSystem = "LV03"
            } else {
                invalid = true
            }

            break

        case 8:
            // Must be a LV03 coordinate with two leading zeros or a LV95 cooridnate with one leading zero

            if firstChar == 1 && secondChar < 4 && lastChar == 0 {
                coordinateType = "LV95N-0"
                coordinateSystem = "LV95"
            } else if firstChar == 2 && secondChar > 4 && lastChar == 0 {
                coordinateType = "LV95E-0"
                coordinateSystem = "LV95"
            } else if firstChar < 4 && secondLastChar == 0 && lastChar == 0 {
                coordinateType = "LV03x-00"
                coordinateSystem = "LV03"
            } else if firstChar > 4 && secondLastChar == 0 && lastChar == 0 {
                coordinateType = "LV03y-00"
                coordinateSystem = "LV03"
            } else {
                invalid = true
            }

            break

        case 9:
            // Must be a LV95 coordinate with two leading zeros

            if firstChar == 1 && secondChar < 4 && secondLastChar == 0 && lastChar == 0 {
                coordinateType = "LV95N-00"
                coordinateSystem = "LV95"
            } else if firstChar == 2 && secondChar > 4 && secondLastChar == 0 && lastChar == 0 {
                coordinateType = "LV95E-00"
                coordinateSystem = "LV95"
            } else {
                invalid = true
            }

            break

        default:
            invalid = true
        }

        debugPrint("coordinateType", coordinateType)

        return (coordinateType, coordinateSystem, invalid)
    }
}
