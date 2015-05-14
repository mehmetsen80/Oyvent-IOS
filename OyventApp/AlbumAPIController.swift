//
//  AlbumAPIController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/13/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation

protocol AlbumAPIControllerProtocol {
    func didReceiveAlbumAPIResults(results: NSDictionary)
}

class AlbumAPIController{
    
    var delegate: AlbumAPIControllerProtocol
    
    init(delegate: AlbumAPIControllerProtocol) {
        self.delegate = delegate
    }
    
    func searchAlbums(currentPage: Int, latitude: String, longitude: String) {
        post(currentPage, latitude: latitude, longitude: longitude)
    }
    
    
    func post(currentPage: Int, latitude: String, longitude: String) {
        
        let url = NSURL(string:"http://oyvent.com/ajax/Feeds.php")
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST";
        var userID:String = NSUserDefaults.standardUserDefaults().stringForKey("userID")! //userID is not being used right now for album class, keep this for future reference
        //println("userID:\(userID)")
        let postString = "processType=GETALBUMLISTNEARBY&userID=\(userID)&currentPage=\(currentPage)&lat=\(latitude)&lng=\(longitude)"
        println("photos postString: \(postString)")
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
                self.delegate.didReceiveAlbumAPIResults(json)
                
            } else {
                //if nil
                let resultString = NSString(data: data, encoding: NSUTF8StringEncoding)
            }
        }
        
        task.resume()
        
    }
}