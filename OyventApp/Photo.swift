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
    
    var pkPhotoID:Double
    var oy:Int
    var lat1:Double
    var long1:Double
    var lat2:Double
    var long2:Double
    var milesGeo:Double
    var milesUser:Double
    var fkTwitterID: String
    var fkInstagramID: String
    var fkFacebookID: String
    var contentLink: String
    var ownedBy: String
    var caption: String
    var createdDate: String
    var postDate: String
    var thumbImageURL: String
    var largeImageURL: String
    var mediumImageURL: String
    var smallImageURL: String
    var albumName: String
    var fkAlbumID:Int
    var fullName: String
    var email: String
    var totalComments: Int
    var hasVoted: Bool
    
  
    init(pkPhotoID: Double, oy:Int, lat1:Double, long1:Double, lat2:Double, long2:Double, milesGeo:Double, milesUser:Double, fkTwitterID:String, fkInstagramID:String, fkFacebookID:String, contentLink:String, ownedBy:String, caption:String, createdDate:String, postDate: String, thumbImageURL: String, largeImageURL: String, mediumImageURL: String, smallImageURL: String, albumName: String, fkAlbumID: Int, fullName: String, email: String, totalComments:Int, hasVoted:Bool){
        self.pkPhotoID = pkPhotoID
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
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                
                var pkPhotoID =  result["PKPHOTOID"] as? Double
                var oy = result["OY"] as? Int
                var lat1 = result["LAT1"] as? Double
                var long1 = result["LONG1"] as? Double
                var lat2 = result["LAT2"] as? Double
                var long2 = result["LONG2"] as? Double
                
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
                
                var fkTwitterID:String? = result["FKTWITTERID"] as? String ?? ""
                var fkInstagramID:String? = result["FKINSTAGRAMID"] as? String ?? ""
                var fkFacebookID:String? = result["FKFACEBOOKID"] as? String ?? ""
                var contentLink:String? = result["CONTENTLINK"] as? String ?? ""
                var ownedBy:String? = result["OWNEDBY"] as? String ?? ""
                var caption:String? = result["CAPTION"] as? String ?? ""
                var createdDate:String? = result["CREATEDDATE"] as? String ?? ""
                var postDate:String? = result["POSTDATE"] as? String ?? ""
                var fullName:String? = result["FULLNAME"] as? String ?? ""
                var email:String? = result["EMAIL"] as? String ?? ""
                var albumName:String? = result["ALBUMNAME"] as? String ?? ""
                var fkAlbumID:Int? =  result["FKALBUMID"] as? Int
                var thumbImageURL:String? = result["URLTHUMB"] as? String ?? ""
                var largeImageURL:String? = result["URLLARGE"] as? String ?? ""
                var mediumImageURL:String? = result["URLMEDIUM"] as? String ?? ""
                var smallImageURL:String? = result["URLSMALL"] as? String ?? ""
                var totalComments = result["TOTALCOMMENTS"] as? Int
                var hasVoted:Bool? = result["HASVOTED"] as? Bool ?? false
                var milesUser:Double? = result["DISTANCE"] as? Double
                milesUser = round(milesUser! * (pow(10.0, 2.0))) / (pow(10.0, 2.0))
                
                var newPhoto = Photo(pkPhotoID: pkPhotoID!, oy:oy!, lat1:lat1!,
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