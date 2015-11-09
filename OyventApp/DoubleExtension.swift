//
//  DoubleExtension.swift
//  OyventApp
//
//  Created by Mehmet Sen on 11/8/15.
//  Copyright © 2015 Oyvent. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}
