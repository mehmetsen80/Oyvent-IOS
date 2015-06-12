//
//  APIController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 3/20/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation

protocol PhotoAPIControllerProtocol {
    func didReceivePhotoAPIResults(results: NSDictionary)
}

class PhotoAPIController{
    
    var delegate: PhotoAPIControllerProtocol
    
    init(delegate: PhotoAPIControllerProtocol) {
        self.delegate = delegate
    }
    
    func searchPhotos(currentPage: Int, latitude: String, longitude: String, albumID: Double, fkParentID: Double) {
        post(currentPage, latitude: latitude, longitude: longitude, albumID: albumID, fkParentID: fkParentID)
    }
    
    
    func post(currentPage: Int, latitude: String, longitude: String, albumID: Double, fkParentID: Double) {
        
        let url = NSURL(string:"http://oyvent.com/ajax/Feeds.php")
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST";
        var userID:String = NSUserDefaults.standardUserDefaults().stringForKey("userID")!
        //println("userID:\(userID)")
        let postString = "processType=GETFEEDLIST&userID=\(userID)&currentPage=\(currentPage)&lat=\(latitude)&lng=\(longitude)&albumID=\(albumID)&fkParentID=\(fkParentID)"
        //println("photos postString: \(postString)")
        var err: NSError?
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
       
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error  in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
        
            
            var err: NSError?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                //println("Dictionary: \(json)")
                self.delegate.didReceivePhotoAPIResults(json)
                
            } else {
                //if nil
                let resultString = NSString(data: data, encoding: NSUTF8StringEncoding)
            }
        }
        
        task.resume()
            
    }
    
}
