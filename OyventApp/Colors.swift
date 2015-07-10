//
//  Colors.swift
//  OyventApp
//
//  Created by Mehmet Sen on 7/6/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation
import UIKit

class Colors {
    //let colorTop = UIColor(red: 0x89/255, green: 0x68/255, blue: 0xCD/255, alpha: 1.0)
    let colorTop = UIColor(red: 0x00/255, green: 0x50/255, blue: 0x7d/255, alpha: 0.8).CGColor
    let colorBottom = UIColor(red: 0x5D/255, green: 0x47/255, blue: 0x8B/255, alpha: 1.0).CGColor
    
    let gl: CAGradientLayer
    
    init() {
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
    }
}