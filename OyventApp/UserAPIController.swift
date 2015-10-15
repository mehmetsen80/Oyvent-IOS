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
        let request = NSMutableURLRequest(URL: url!)
        //var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST";
        //myUserID is not used for now
        let myUserID:String = NSUserDefaults.standardUserDefaults().stringForKey("userID")!
        let postString = "processType=GETPROFILE&userID=\(pkUserID)"
        print("post profile postString: \(postString)", terminator: "")
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
                self.delegate.didReceiveUserAPIResults(json)
                
            } catch {
                //if nil
                //let resultString = NSString(data: data, encoding: NSUTF8StringEncoding)
                print("Fetch failed: \((error as NSError).localizedDescription)")
            }
        }
        
        task.resume()
    }
}