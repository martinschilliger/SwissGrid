//
//  CLLocation+CH1903.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 19.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//
//  Based on: http://github.com/jonasschnelli/CLLocation-CH1903
//  CLLocation+CH1903.m
//  g7
//
//  Created by Jonas Schnelli on 22.04.10.
//  Copyright 2010 include7 AG. All rights reserved.

import Foundation

class CLLocation1903 {

    // TODO: Insert the requests to https://geodesy.geo.admin.ch/reframe/lv95towgs84 also as functions here?

    func CHtoWGSlat(x: Double, y: Double) -> Double {
        // Converts militar to civil and to unit = 1000km
        // Axiliary values (% Bern)
        let y_aux = (y - 600_000) / 1_000_000.0
        let x_aux = (x - 200_000) / 1_000_000.0

        // Process lat
        var lat = 16.9023892
            + 3.238272 * x_aux
            - 0.270978 * pow(y_aux, 2)
            - 0.002528 * pow(x_aux, 2)
            - 0.0447 * pow(y_aux, 2) * x_aux
            - 0.0140 * pow(x_aux, 3)

        // Unit 10000" to 1 " and converts seconds to degrees (dec)
        lat = lat * 100 / 36.0

        return lat
    }

    func CHtoWGSlong(x: Double, y: Double) -> Double {
        // Converts militar to civil and  to unit = 1000km
        // Axiliary values (% Bern)
        let y_aux = (y - 600_000) / 1_000_000.0
        let x_aux = (x - 200_000) / 1_000_000.0

        // Process long
        var lng = 2.6779094
            + 4.728982 * y_aux
            + 0.791484 * y_aux * x_aux
            + 0.1306 * y_aux * pow(x_aux, 2)
            - 0.0436 * pow(y_aux, 3)

        // Unit 10000" to 1 " and converts seconds to degrees (dec)
        lng = lng * 100 / 36.0

        return lng
    }

    func WGStoCHy(lat: Double, lng: Double) -> Double {
        // Converts degrees dec to sex
        var lat = decToSex(lat)
        var lng = decToSex(lng)

        // Converts degrees to seconds (sex)
        lat = degToSec(lat)
        lng = degToSec(lng)

        // Axiliary values (% Bern)
        let lat_aux = (lat - 169_028.66) / 10000
        let lng_aux = (lng - 26782.5) / 10000

        // Process Y
        let y = 600_072.37 + 211_455.93 * lng_aux - 10938.51 * lng_aux * lat_aux - 0.36 * lng_aux * pow(lat_aux, 2) - 44.54 * pow(lng_aux, 3)

        return y
    }

    func WGStoCHx(lat: Double, lng: Double) -> Double {
        // Converts degrees dec to sex
        var lat = decToSex(lat)
        var lng = decToSex(lng)

        // Converts degrees to seconds (sex)
        lat = degToSec(lat)
        lng = degToSec(lng)

        // Axiliary values (% Bern)
        let lat_aux = (lat - 169_028.66) / 10000
        let lng_aux = (lng - 26782.5) / 10000

        // Process Y
        let x = 200_147.07 + 308_807.95 * lat_aux + 3745.25 * pow(lng_aux, 2) + 76.63 * pow(lat_aux, 2) - 194.56 * pow(lng_aux, 2) * lat_aux + 119.79 * pow(lat_aux, 3)

        return x
    }

    // Convert DEC angle to SEX DMS
    func decToSex(_ angle: Double) -> Double {
        // Extract DMS
        let deg = Double(Int(angle))
        let min = Double(Int((angle - deg) * 60))
        let sec = (((angle - deg) * 60) - min) * 60

        // Result in degrees sex (dd.mmss)
        return deg + min / 100 + sec / 10000.0
    }

    func degToSec(_ angle: Double) -> Double {
        // Extract DMS
        let deg = Double(Int(angle))
        let min = Double(Int((angle - deg) * 100))
        let sec = (((angle - deg) * 100.0) - min) * 100.0

        // Result in degrees sex (dd.mmss)
        return sec + min * 60.0 + deg * 3600.0
    }

    func sexToDec(_ angle: Double) -> Double {
        // Extract DMS
        let deg = Double(Int(angle))
        let min = Double(Int((angle - deg) * 100))
        let sec = (((angle - deg) * 100.0) - min) * 100.0

        // Result in degrees sex (dd.mmss)
        return deg + (sec / 60.0 + min) / 60.0
    }
}
