//
//  CustomView.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/5/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation
import UIKit

class CustomView : UIView {
    
    required init?(coder decoder: NSCoder) {

        super.init(coder: decoder)
        
        // backgroundColor = UIColor.whiteColor()
        backgroundColor = UIColor(red: 0x04/255, green: 0x7f/255, blue: 0xb7/255, alpha: 1.0)
        //or = [UIColor greenColor].CGColor; //=UIColor(red: 0x04/255, green: 0x7f/255, blue: 0xb7/255, alpha: 1.0).CGColor
        
    }
    
    override func drawRect(rect: CGRect) {
        updateLayerProperties()
    }
    
    func updateLayerProperties() {
        layer.masksToBounds = true
        layer.cornerRadius = 12.0
        layer.shadowColor = UIColor.blueColor().CGColor
    }
    
}
