//
//  JSONlv95towgs84.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 11.10.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import Foundation
import ObjectMapper

class JSONlv95towgs84Response: Mappable {
   
    var easting: String?
    var northing: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        easting <- map["easting"]
        northing <- map["northing"]
    }
}

