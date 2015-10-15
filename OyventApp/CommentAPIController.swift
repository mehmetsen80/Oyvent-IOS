//
//  CommentAPIController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/3/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation

protocol CommentAPIControllerProtocol {
    func didReceiveCommentAPIResults(results: NSDictionary)
}

class CommentAPIController{
    
    var delegate: CommentAPIControllerProtocol
    
    init(delegate: CommentAPIControllerProtocol) {
        self.delegate = delegate
    }
    
    func searchComments(photoID: Double) {
        post(photoID)
    }
    
    
    func post(photoID: Double) {
        
        let url = NSURL(string:"http://oyvent.com/ajax/Feeds.php")
        let request = NSMutableURLRequest(URL: url!)
        //var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST";
        let postString = "processType=GETCOMMENTS&photoID=\(photoID)"
        print("Comment postString: \(postString)", terminator: "")
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error  in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription, terminator: "")
            }
            
            
            do{
             let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                //print("Comments Dictionary: \(json)")
                self.delegate.didReceiveCommentAPIResults(json)
                
            } catch {
                //if nil
                //let resultString = NSString(data: data, encoding: NSUTF8StringEncoding)
                print("Fetch failed: \((error as NSError).localizedDescription)")
            }
        }
        
        task.resume()
    }
}