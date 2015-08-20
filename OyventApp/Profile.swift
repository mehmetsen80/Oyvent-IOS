//
//  Profile.swift
//  OyventApp
//
//  Created by Mehmet Sen on 8/6/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation

class Profile{
    
    var pkUserID: Double?
    var fullName: String?
    var urlLarge: String?
    var urlMedium: String?
    var urlSmall: String?
    var urlThumb: String?
  
    
    class func profileWithJSON(allResults: NSDictionary) -> Profile{
        
        var profile : Profile = Profile()
        //store results in our table data array, in fact we have here only one item
        /*if(allResults.count>0) {
            
            // get the all album list
            for result in allResults {
            
                let pkUserID = result["PKUSERID"] as? Double
                let fullName = result["FULLNAME"] as? String
                profile.fullName = fullName
                profile.pkUserID = pkUserID
            }
            
        }*/
        
        profile.pkUserID = allResults["PKUSERID"] as? Double
        profile.fullName = allResults["FULLNAME"] as? String
        profile.urlLarge = allResults["URLLARGE"] as? String ?? ""
        profile.urlMedium = allResults["URLMEDIUM"] as? String ?? ""
        profile.urlSmall = allResults["URLSMALL"] as? String ?? ""
        profile.urlThumb = allResults["URLTHUMB"] as? String ?? ""
        
        return profile;
    }
}