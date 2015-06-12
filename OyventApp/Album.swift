//
//  Album.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/13/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation

class Album{
    
    let pkAlbumID: Double?
    let fkUserID: Double?
    let fkParentID: Double?
    let fkCategoryID: Double?
    let albumName: String?
    let albumUserName: String?
    let parentName: String?
    let latitude: Double?
    let longitude: Double?
    let postDate: String?
    let address: String?
    let radius: Float?
    let milesUser:Double = 0
    
    init(pkAlbumID: Double, albumName: String){
        self.pkAlbumID = pkAlbumID
        self.albumName = albumName
    }
    
    init(pkAlbumID: Double, fkUserID: Double, fkParentID: Double, fkCategoryID: Double, albumName: String, albumUserName: String, parentName: String,
        latitude: Double, longitude: Double, postDate: String, address: String, radius: Float, milesUser:Double){
        
            self.pkAlbumID = pkAlbumID
            self.fkUserID = fkUserID
            self.fkParentID = fkParentID
            self.fkCategoryID = fkCategoryID
            self.albumName = albumName
            self.albumUserName = albumUserName
            self.parentName = parentName
            self.latitude = latitude
            self.longitude = longitude
            self.postDate = postDate
            self.address = address
            self.radius = radius
            self.milesUser = milesUser
    }
    
    class func albumsWithJSON(allResults: NSArray) -> [Album] {
        
        // Create an empty array of Album to append to from this list
        var albums = [Album]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            // get the all album list
            for result in allResults {
                
                var pkAlbumID =  result["PKALBUMID"] as? Double
                var fkUserID = result["FKUSERID"] as? Double
                var fkParentID = result["FKPARENTID"] as? Double
                var fkCategoryID = result["FKCATEGORYID"] as? Double
                var albumName: String? = result["ALBUMNAME"] as? String ?? ""
                var albumUserName: String?  = result["ALBUMUSERNAME"] as? String ?? ""
                var parentName: String? = result["PARENTNAME"] as? String ?? "All Categories"
                var latitude = result["LATITUDE"] as? Double
                var longitude = result["LONGITUDE"] as? Double
                var postDate:String? = result["POSTDATE"] as? String ?? ""
                var address:String? = result["ADDRESS"] as? String ?? ""
                var radius:Float? = result["RADIUS"] as? Float
                var milesUser:Double? = result["DISTANCE"] as? Double
                milesUser = round(milesUser! * (pow(10.0, 2.0))) / (pow(10.0, 2.0))
                
                var album = Album(pkAlbumID: pkAlbumID!, fkUserID: fkUserID!, fkParentID: fkParentID!, fkCategoryID: fkCategoryID!, albumName: albumName!, albumUserName: albumUserName!, parentName: parentName!, latitude: latitude!, longitude: longitude!, postDate: postDate!, address: address!, radius: radius!, milesUser:milesUser!)
                albums.append(album)
            }
        }
        
        return albums
    }
}