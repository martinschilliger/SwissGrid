//
//  Colors.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 23.10.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import Foundation
import UIKit

enum Colors {
    case LightBackground, ErrorBackground
    func color() -> UIColor {
        switch self {
        case .LightBackground:
            return UIColor(red: 0.710, green: 0.557, blue: 0.404, alpha: 1)
        case .ErrorBackground:
            return UIColor(red: 0.827, green: 0.298, blue: 0.298, alpha: 1)
        }
    }
}
