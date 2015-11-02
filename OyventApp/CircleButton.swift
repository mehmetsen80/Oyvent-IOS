//
//  CircleButton.swift
//  OyventApp
//
//  Created by Mehmet Sen on 8/8/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation
import UIKit

class CircleButton: UIButton {

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        //backgroundColor = UIColor(red: 0x04/255, green: 0x7f/255, blue: 0xb7/255, alpha: 1.0)
    }
    
    override func drawRect(rect: CGRect) {
        updateLayerProperties()
    }
    
    func updateLayerProperties() {
        layer.masksToBounds = true
        layer.cornerRadius = 120.0
        //layer.shadowColor = UIColor.blueColor().CGColor
        
        
        //superview is your optional embedding UIView
        /*if let superview = superview {
            superview.backgroundColor = UIColor(red: 0xff/255, green: 0xff/255, blue: 0xff/255, alpha: 1.0)//00507d
            superview.layer.shadowColor = UIColor.darkGrayColor().CGColor
            superview.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12.0).CGPath
            superview.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            superview.layer.shadowOpacity = 1.0
            superview.layer.shadowRadius = 2
            superview.layer.masksToBounds = true
            superview.clipsToBounds = false
            
        }*/
    }

    
}
