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
    
    func searchAllAlbums(currentPage: Int, latitude: String, longitude: String, pkAlbumID: Double!) {
        postAll(currentPage, latitude: latitude, longitude: longitude, pkAlbumID: pkAlbumID)
    }
    
    func searchParentAlbums(currentPage: Int, latitude: String, longitude: String) {
        postParent(currentPage, latitude: latitude, longitude: longitude)
    }
    
    func postAll(currentPage: Int, latitude: String, longitude: String, pkAlbumID: Double) {
        
        let url = NSURL(string:"http://oyvent.com/ajax/Feeds.php")
        let request = NSMutableURLRequest(URL: url!)
        //var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST";
        let userID:String = NSUserDefaults.standardUserDefaults().stringForKey("userID")! //userID is not being used right now for album class, keep this for future reference
        //println("userID:\(userID)")
        let postString = "processType=GETALLALBUMLISTNEARBY&userID=\(userID)&currentPage=\(currentPage)&lat=\(latitude)&lng=\(longitude)&pkAlbumID=\(pkAlbumID)"
        print("post All albums postString: \(postString)", terminator: "")
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error  in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription, terminator: "")
            }
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                //println("Dictionary: \(json)")
                self.delegate.didReceiveAlbumAPIResults(json)
                
            } catch  {
                //if nil
                //let resultString: NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                //print(resultString, terminator: "")
                print("Fetch failed: \((error as NSError).localizedDescription)")
            }
            
        }
        
        task.resume()
        
    }
    
    func postParent(currentPage: Int, latitude: String, longitude: String) {
        
        let url = NSURL(string:"http://oyvent.com/ajax/Feeds.php")
        let request = NSMutableURLRequest(URL: url!)
        //var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST";
        let userID:String = NSUserDefaults.standardUserDefaults().stringForKey("userID")! //userID is not being used right now for album class, keep this for future reference
        //println("userID:\(userID)")
        let postString = "processType=GETPARENTALBUMLISTNEARBY&userID=\(userID)&currentPage=\(currentPage)&lat=\(latitude)&lng=\(longitude)"
        print("photos Parent Albums postString: \(postString)", terminator: "")
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error  in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription, terminator: "")
            }
            
            
            do{
             let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                //println("Dictionary: \(json)")
                self.delegate.didReceiveAlbumAPIResults(json)
                
            } catch {
                //if nil
                //let resultString = NSString(data: data, encoding: NSUTF8StringEncoding)
                print("Fetch failed: \((error as NSError).localizedDescription)")
            }
        }
        
        task.resume()
        
    }

    
}