//
//  MutableExtension.swift
//  OyventApp
//
//  Created by Mehmet Sen on 11/1/15.
//  Copyright © 2015 Oyvent. All rights reserved.
//

import Foundation

//used in photo capture
extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
