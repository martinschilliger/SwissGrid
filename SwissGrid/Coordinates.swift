//
//  Coordinates.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 18.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import Foundation
import UIKit
import Whisper

class Coordinates {

    // Parse the String from the coordinateInput and make Ints from it
    // E: 0 && N: 0 means invalid coordinates
    func parseCoordinates(coordinates: String) -> (Ey: Int, Nx: Int, LV95: Bool) {

        // Replace everything but numbers
        let regexOnlyNumbers = try! NSRegularExpression(pattern: "([\\D])", options: NSRegularExpression.Options.caseInsensitive)
        let regexRange = NSMakeRange(0, coordinates.characters.count)
        let coordinatesOnlyNumbers = regexOnlyNumbers.stringByReplacingMatches(in: coordinates, options: [], range: regexRange, withTemplate: "")

        let parsedCoordinates = checkCoordinatesValidityAndConvertToInts(coordinates: coordinatesOnlyNumbers)

        return (parsedCoordinates.Ey, parsedCoordinates.Nx, parsedCoordinates.LV95)
    }

    // Cut the coordinates string and check validity
    // important note: returns coordinats without prefix even if LV95 is used!
    func checkCoordinatesValidityAndConvertToInts(coordinates: String) -> (valid: Bool, Ey: Int, Nx: Int, LV95: Bool) {
        var coordinate1 = String()
        var coordinate2 = String()
        var coordinateNx = Int()
        var coordinateEy = Int()

        // Only even numbers can be a valid coordinates-pair
        if coordinates.characters.count < 12 {
            debugPrint("Coordinates invalid: not enough numbers")
            return (false, 0, 0, false)
        }

        // Only even numbers can be a valid coordinates-pair
        if coordinates.characters.count % 2 != 0 {
            debugPrint("Coordinates invalid: odd number count")
            return (false, 0, 0, false)
        }

        // Find out the type of coordinates
        let middleIndex = coordinates.index(coordinates.startIndex, offsetBy: (coordinates.characters.count / 2))
        coordinate1 = String(coordinates.prefix(upTo: middleIndex))
        coordinate2 = String(coordinates.suffix(from: middleIndex))

        let coordinate1Type = findCoordinateType(coordinate: coordinate1)
        let coordinate2Type = findCoordinateType(coordinate: coordinate2)

        // Proofing, if all coordinates are valid
        if coordinate1Type.invalid || coordinate2Type.invalid || coordinate1Type.coordinateSystem != coordinate2Type.coordinateSystem {
            debugPrint("Coordinates invalid while looking for type")
            let msg = NSLocalizedString("Entered invalid coordinates", comment: "")
            let murmur = Murmur(title: msg, backgroundColor: Colors.LightBackground.color(), titleColor: UIColor.black)
            Whisper.show(whistle: murmur, action: .show(2.5))
            return (false, 0, 0, false)
        } else {
//            Inform the user about his input
            let msg = String(format: NSLocalizedString("Entered %@ coordinates", comment: "Shows the coordinate system used"), coordinate1Type.coordinateSystem)
            let murmur = Murmur(title: msg, backgroundColor: Colors.LightBackground.color(), titleColor: UIColor.black)
            Whisper.show(whistle: murmur, action: .show(2.5))
        }

        // cut the coordinate out of the string
        let coordinate1calculated = coordinateCutPrefixSuffixAndConvertToInt(coordinate: coordinate1, coordinateType: coordinate1Type.coordinateType)
        let coordinate2calculated = coordinateCutPrefixSuffixAndConvertToInt(coordinate: coordinate2, coordinateType: coordinate2Type.coordinateType)
        //        debugPrint(coordinate1calculated)
        //        debugPrint(coordinate2calculated)

        // Proofing, if two different coordinate directinos have been entered
        if coordinate1calculated.direction == coordinate2calculated.direction {
            debugPrint("Coordinates invalid, 2x the same direction")
            let msg: String
            if coordinate1calculated.direction == "Nx" {
                msg = NSLocalizedString("Invalid: Entered two northing coordinates", comment: "2x same direction (north) entred")
            } else {
                msg = NSLocalizedString("Invalid: Entered two easting coordinates", comment: "2x same direction (east) entred")
            }
            let murmur = Murmur(title: msg, backgroundColor: Colors.ErrorBackground.color(), titleColor: UIColor.white)
            Whisper.show(whistle: murmur, action: .show(5))
            return (false, 0, 0, false)
        }

        // Assign coordinate1
        if coordinate1calculated.direction == "Nx" {
            coordinateNx = coordinate1calculated.coordinate
        } else if coordinate1calculated.direction == "Ey" {
            coordinateEy = coordinate1calculated.coordinate
        }
        // Assign coordinate2
        if coordinate2calculated.direction == "Nx" {
            coordinateNx = coordinate2calculated.coordinate
        } else if coordinate2calculated.direction == "Ey" {
            coordinateEy = coordinate2calculated.coordinate
        }

        //        debugPrint("coordinateNx", coordinateNx)
        //        debugPrint("coordinateEy", coordinateEy)

        return (true, coordinateEy, coordinateNx, coordinate1Type.coordinateSystem == "LV95")
    }

    // Find out the validity of one (!) coordinate and its type
    func findCoordinateType(coordinate: String) -> (coordinateType: String, coordinateSystem: String, invalid: Bool) {
        var coordinateType = String()
        var coordinateSystem = String()
        var invalid = false

        // Find number at position and convert to int for further evaluating
        let firstChar = Int("\(coordinate[coordinate.startIndex])")!
        let secondChar = Int("\(coordinate[coordinate.index(coordinate.startIndex, offsetBy: 1)])")!
        let secondLastChar = Int("\(coordinate[coordinate.index(coordinate.endIndex, offsetBy: -2)])")!
        let lastChar = Int("\(coordinate[coordinate.index(coordinate.endIndex, offsetBy: -1)])")!

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
            } else if firstChar == 2 && secondChar >= 4 {
                coordinateType = "LV95E"
                coordinateSystem = "LV95"
            } else if firstChar < 4 && lastChar == 0 {
                coordinateType = "LV03x-0"
                coordinateSystem = "LV03"
            } else if firstChar >= 4 && lastChar == 0 {
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
            } else if firstChar == 2 && secondChar >= 4 && lastChar == 0 {
                coordinateType = "LV95E-0"
                coordinateSystem = "LV95"
            } else if firstChar < 4 && secondLastChar == 0 && lastChar == 0 {
                coordinateType = "LV03x-00"
                coordinateSystem = "LV03"
            } else if firstChar >= 4 && secondLastChar == 0 && lastChar == 0 {
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
            } else if firstChar == 2 && secondChar >= 4 && secondLastChar == 0 && lastChar == 0 {
                coordinateType = "LV95E-00"
                coordinateSystem = "LV95"
            } else {
                invalid = true
            }

            break

        default:
            invalid = true
        }

        return (coordinateType, coordinateSystem, invalid)
    }

    // Cuts the prefix and suffix and converts to Int
    func coordinateCutPrefixSuffixAndConvertToInt(coordinate: String, coordinateType: String) -> (coordinate: Int, direction: String) {
        var coordinate = coordinate // convert to mutable variable
        var direction = String()

        let prefix = String(coordinateType.characters.prefix(4))
        let suffix = String(coordinateType.characters.suffix(2))

        let directionIndex = coordinateType.index(coordinateType.startIndex, offsetBy: 4)

        // Cut prefix if necessary
        //        debugPrint("Prefix: ", prefix)
        if prefix == "LV95" {
            coordinate.characters.removeFirst(1)
        }

        // Cut suffix if necessary
        //        debugPrint("Suffix: ", suffix)
        if suffix == "-0" {
            coordinate.characters.removeLast(1)
        } else if suffix == "00" {
            coordinate.characters.removeLast(2)
        }

        // Find out the direction
        //        debugPrint(coordinateType[directionIndex])
        switch coordinateType[directionIndex] {
        case "N", "x":
            direction = "Nx"
            break
        case "E", "y":
            direction = "Ey"
            break
        default:
            break
        }

        return (Int(coordinate)!, direction)
    }
}
