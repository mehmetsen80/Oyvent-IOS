//
//  Photo.swift
//  OyventApp
//
//  Created by Mehmet Sen on 3/19/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation
import CoreLocation


class Photo{
    
    let pkPhotoID:Double
    let fkUserID:Double
    let oy:Int
    let lat1:Double
    let long1:Double
    let lat2:Double
    let long2:Double
    let milesGeo:Double
    let milesUser:Double
    let fkTwitterID: String
    let fkInstagramID: String
    let fkFacebookID: String
    let contentLink: String
    let ownedBy: String
    let caption: String
    let createdDate: String
    let postDate: String
    let thumbImageURL: String
    let largeImageURL: String
    let mediumImageURL: String
    let smallImageURL: String
    let albumName: String
    let fkAlbumID:Double
    let fullName: String
    let email: String
    let totalComments: Int
    let hasVoted: Bool
    
  
    init(pkPhotoID: Double, fkUserID: Double, oy:Int, lat1:Double, long1:Double, lat2:Double, long2:Double, milesGeo:Double, milesUser:Double, fkTwitterID:String, fkInstagramID:String, fkFacebookID:String, contentLink:String, ownedBy:String, caption:String, createdDate:String, postDate: String, thumbImageURL: String, largeImageURL: String, mediumImageURL: String, smallImageURL: String, albumName: String, fkAlbumID: Double, fullName: String, email: String, totalComments:Int, hasVoted:Bool){
        self.pkPhotoID = pkPhotoID
        self.fkUserID = fkUserID
        self.oy = oy
        self.lat1 = lat1
        self.long1 = long1
        self.lat2 = lat2
        self.long2 = long2
        self.milesGeo = milesGeo
        self.milesUser = milesUser
        self.fkTwitterID = fkTwitterID
        self.fkInstagramID = fkInstagramID
        self.fkFacebookID = fkFacebookID
        self.contentLink = contentLink
        self.ownedBy = ownedBy
        self.caption = caption
        self.createdDate = createdDate
        self.postDate = postDate
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.mediumImageURL = mediumImageURL
        self.smallImageURL = smallImageURL
        self.albumName = albumName
        self.fkAlbumID = fkAlbumID
        self.fullName = fullName
        self.email = email
        self.totalComments = totalComments
        self.hasVoted = hasVoted
    }
   
    
    
    class func photosWithJSON(allResults: NSArray) -> [Photo] {
    
       
        // Create an empty array of Photos to append to from this list
        var photos = [Photo]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            // get the all photo list
            for result in allResults {
                
                let pkPhotoID =  result["PKPHOTOID"] as? Double
                let fkUserID = result["FKUSERID"] as? Double
                let oy = result["OY"] as? Int
                let lat1 = result["LAT1"] as? Double
                let long1 = result["LONG1"] as? Double
                let lat2 = result["LAT2"] as? Double
                let long2 = result["LONG2"] as? Double
                
                var milesGeo:Double = 0
               
                if(lat1 != nil && long1 != nil && lat2 != nil && long2 != nil){
                    //println("lat1: \(lat1!) long1:\(long1!) lat2:\(lat2!) long2:\(long2!)")
                  
                    let loc1: CLLocation = CLLocation(latitude: lat1!, longitude: long1!)
                    let loc2: CLLocation = CLLocation(latitude: lat2!, longitude: long2!)
//
//                    let loc1: CLLocation = CLLocation(latitude: 34.72215, longitude: -92.33853999999999)
//                    let loc2: CLLocation = CLLocation(latitude: 34.710098, longitude: -92.35452592660501)
                    //in 1 km 0.000621371 miles
                    milesGeo = (loc1.distanceFromLocation(loc2)/1000) * 0.621371
//                    println("milesGeo: \(miles) ")
//                    let numberOfPlaces = 2.0
//                    let multiplier = pow(10.0, numberOfPlaces)
//                    milesGeo = round(milesGeo * multiplier) / multiplier
                    milesGeo = round(milesGeo * (pow(10.0, 2.0))) / (pow(10.0, 2.0))
//                    println("distance: \(milesGeo) milesGeo")
//                    var nf: NSNumberFormatter = NSNumberFormatter()
//                    nf.maximumFractionDigits = 2
//                    println("\(nf.stringFromNumber(milesGeo)!)")
                   
                    
                }
                
                let fkTwitterID:String? = result["FKTWITTERID"] as? String ?? ""
                let fkInstagramID:String? = result["FKINSTAGRAMID"] as? String ?? ""
                let fkFacebookID:String? = result["FKFACEBOOKID"] as? String ?? ""
                let contentLink:String? = result["CONTENTLINK"] as? String ?? ""
                let ownedBy:String? = result["OWNEDBY"] as? String ?? ""
                let caption:String? = result["CAPTION"] as? String ?? ""
                let createdDate:String? = result["CREATEDDATE"] as? String ?? ""
                let postDate:String? = result["POSTDATE"] as? String ?? ""
                let fullName:String? = result["FULLNAME"] as? String ?? ""
                let email:String? = result["EMAIL"] as? String ?? ""
                let albumName:String? = result["ALBUMNAME"] as? String ?? ""
                let fkAlbumID:Double? =  result["FKALBUMID"] as? Double
                let thumbImageURL:String? = result["URLTHUMB"] as? String ?? ""
                let largeImageURL:String? = result["URLLARGE"] as? String ?? ""
                let mediumImageURL:String? = result["URLMEDIUM"] as? String ?? ""
                let smallImageURL:String? = result["URLSMALL"] as? String ?? ""
                let totalComments = result["TOTALCOMMENTS"] as? Int
                let hasVoted:Bool? = result["HASVOTED"] as? Bool ?? false
                var milesUser:Double? = result["DISTANCE"] as? Double
                milesUser = round(milesUser! * (pow(10.0, 2.0))) / (pow(10.0, 2.0))
                
                var newPhoto = Photo(pkPhotoID: pkPhotoID!, fkUserID: fkUserID!, oy:oy!, lat1:lat1!,
                    long1:long1!, lat2:lat2!, long2:long2!, milesGeo:milesGeo, milesUser:milesUser!, fkTwitterID:fkTwitterID!, fkInstagramID:fkInstagramID!, fkFacebookID:fkFacebookID!, contentLink:contentLink!, ownedBy:ownedBy!, caption:caption!, createdDate:createdDate!, postDate: postDate!,
                    thumbImageURL: thumbImageURL!, largeImageURL: largeImageURL!,
                    mediumImageURL: mediumImageURL!, smallImageURL: smallImageURL!,
                    albumName: albumName!, fkAlbumID: fkAlbumID!, fullName: fullName!, email: email!, totalComments: totalComments!, hasVoted:hasVoted!)
                photos.append(newPhoto)
                
            }
        }
        
        
        return photos
    }


}