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
    let milesUser:Double?
    let photoSize: Int?
    let totalPhotoSize: Int?
    let urlLarge: String?
    let urlMedium: String?
    let urlSmall: String?
    let urlThumb: String?
    
    init(pkAlbumID: Double, albumName: String){
        self.pkAlbumID = pkAlbumID
        self.albumName = albumName
        
        self.fkUserID = 0
        self.fkParentID = 0
        self.fkCategoryID  = 0
        self.albumUserName = ""
        self.parentName = ""
        self.latitude = 0
        self.longitude = 0
        self.postDate = ""
        self.address = ""
        self.radius = 0.0
        self.milesUser = 0
        self.photoSize = 0
        self.totalPhotoSize = 0
        self.urlLarge = ""
        self.urlMedium = ""
        self.urlSmall = ""
        self.urlThumb = ""
        
    }
    
    init(pkAlbumID: Double, fkUserID: Double, fkParentID: Double, fkCategoryID: Double, albumName: String, albumUserName: String, parentName: String,
        latitude: Double, longitude: Double, postDate: String, address: String, radius: Float, milesUser: Double, photoSize: Int, totalPhotoSize: Int, urlLarge: String, urlMedium: String, urlSmall: String, urlThumb: String){
        
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
            self.photoSize = photoSize
            self.totalPhotoSize = totalPhotoSize
            self.urlLarge = urlLarge
            self.urlMedium = urlMedium
            self.urlSmall = urlSmall
            self.urlThumb = urlThumb
    }
    
    class func albumsWithJSON(allResults: NSArray) -> [Album] {
        
        // Create an empty array of Album to append to from this list
        var albums = [Album]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            // get the all album list
            for result in allResults {
                
                let pkAlbumID =  result["PKALBUMID"] as? Double
                let fkUserID = result["FKUSERID"] as? Double
                let fkParentID = result["FKPARENTID"] as? Double
                let fkCategoryID = result["FKCATEGORYID"] as? Double
                let albumName: String? = result["ALBUMNAME"] as? String ?? ""
                let albumUserName: String?  = result["ALBUMUSERNAME"] as? String ?? ""
                let parentName: String? = result["PARENTNAME"] as? String ?? ""
                let latitude = result["LATITUDE"] as? Double
                let longitude = result["LONGITUDE"] as? Double
                let postDate: String? = result["POSTDATE"] as? String ?? ""
                let address: String? = result["ADDRESS"] as? String ?? ""
                let radius: Float? = result["RADIUS"] as? Float
                var milesUser: Double? = result["DISTANCE"] as? Double
                milesUser = round(milesUser! * (pow(10.0, 2.0))) / (pow(10.0, 2.0))
                let photoSize = result["PHOTOSIZE"] as? Int
                let totalPhotoSize = result["TOTALPHOTOSIZE"] as? Int
                let urlLarge: String? = result["URLLARGE"] as? String ?? ""
                let urlMedium: String? = result["URLMEDIUM"] as? String ?? ""
                let urlSmall: String? = result["URLSMALL"] as? String ?? ""
                let urlThumb: String? = result["URLTHUMB"] as? String ?? ""
                
                let album = Album(pkAlbumID: pkAlbumID!, fkUserID: fkUserID!, fkParentID: fkParentID!, fkCategoryID: fkCategoryID!, albumName: albumName!, albumUserName: albumUserName!, parentName: parentName!, latitude: latitude!, longitude: longitude!, postDate: postDate!, address: address!, radius: radius!, milesUser: milesUser!, photoSize: photoSize!, totalPhotoSize: totalPhotoSize!, urlLarge: urlLarge!, urlMedium: urlMedium!, urlSmall: urlSmall!, urlThumb: urlThumb!)
                albums.append(album)
            }
        }
        
        return albums
    }
}