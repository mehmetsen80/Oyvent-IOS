//
//  Comment.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/3/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation

class Comment{
    
    var pkCommentID: Double?
    var fkPhotoID: Double?
    var fkUserID: Double?
    var fullName: String?
    var message: String?
    var latitude: Double?
    var longitude: Double?
    var postDate: String?
    var email: String?
    
    
    init(fullName: String, message: String){
        
        self.fullName = fullName
        self.message = message
  
    }
    
    init(pkCommentID: Double, fkPhotoID: Double, fkUserID: Double, fullName: String, message: String, latitude: Double, longitude: Double, postDate: String, email: String){
        
        self.pkCommentID = pkCommentID
        self.fkPhotoID = fkPhotoID
        self.fkUserID = fkUserID
        self.fullName = fullName
        self.message = message
        self.latitude = latitude
        self.longitude = longitude
        self.postDate = postDate
        self.email = email
    }
    
    class func commentsWithJSON(allResults: NSArray) -> [Comment] {
    
        // Create an empty array of Comment to append to from this list
        var comments = [Comment]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                
                var pkCommentID =  result["PKCOMMENTID"] as? Double
                var fkPhotoID = result["FKPHOTOID"] as? Double
                var fkUserID = result["FKUSERID"] as? Double
                var fullName: String? = result["FULLNAME"] as? String ?? ""
                var message: String?  = result["COMMENT"] as? String ?? ""
                var latitude = result["LATITUDE"] as? Double
                var longitude = result["LONGITUDE"] as? Double
                var postDate:String? = result["POSTDATE"] as? String ?? ""
                var email:String? = result["EMAIL"] as? String ?? ""
              
                var comment = Comment(pkCommentID: pkCommentID!, fkPhotoID: fkPhotoID!, fkUserID: fkUserID!, fullName: fullName!, message: message!, latitude: latitude!, longitude: longitude!, postDate: postDate!, email: email!)
                comments.append(comment)
            }
        }
        
        return comments
    }
}