//
//  UserAPIController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 8/7/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation

protocol UserAPIControllerProtocol {
    func didReceiveUserAPIResults(results: NSDictionary)
}

class UserAPIController{
    
    var delegate: UserAPIControllerProtocol
    
    init(delegate: UserAPIControllerProtocol) {
        self.delegate = delegate
    }
    
    func searchProfile(pkUserID: Double) {
        post(pkUserID)
    }
    
    func post(pkUserID: Double){
        let url = NSURL(string:"http://oyvent.com/ajax/Feeds.php")
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST";
        //myUserID is not used for now
        var myUserID:String = NSUserDefaults.standardUserDefaults().stringForKey("userID")!
        let postString = "processType=GETPROFILE&userID=\(pkUserID)"
        println("post profile postString: \(postString)")
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
                self.delegate.didReceiveUserAPIResults(json)
                
            } else {
                //if nil
                let resultString = NSString(data: data, encoding: NSUTF8StringEncoding)
            }
        }
        
        task.resume()
    }
}