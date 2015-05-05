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
    
    func searchPhotos(photoID: Double) {
        let urlPath = "http://oyvent.com/ajax/Feeds.php?"
        post(urlPath, photoID: photoID)
    }
    
    
    func post(path: String, photoID: Double) {
        
        let url = NSURL(string:"http://oyvent.com/ajax/Feeds.php")
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST";
        let postString = "processType=GETCOMMENTS&photoID=\(photoID)"
        println("Comment postString: \(postString)")
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
                println("Comments Dictionary: \(json)")
                self.delegate.didReceiveCommentAPIResults(json)
                
            } else {
                //if nil
                let resultString = NSString(data: data, encoding: NSUTF8StringEncoding)
            }
        }
        
        task.resume()
    }
}