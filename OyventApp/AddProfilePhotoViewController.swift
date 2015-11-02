//
//  AddProfilePhotoViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 10/14/15.
//  Copyright © 2015 Oyvent. All rights reserved.
//

import UIKit
import Haneke

class AddProfilePhotoViewController: UIViewController, ProfileAPIControllerProtocol {

    
    var userApi:ProfileAPIController?
    private let concurrentProfileQueue = dispatch_queue_create(
        "com.oy.vent.profileQueue", DISPATCH_QUEUE_CONCURRENT)
    var pkUserID : Double!
    var url: String!
    
    @IBOutlet weak var btnPhoto: CircleButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //get user id from saved disk
        pkUserID =  NSNumberFormatter().numberFromString(NSUserDefaults.standardUserDefaults().stringForKey("userID")!)?.doubleValue
        
        //if user id is ok then get profile photo
        if(pkUserID != nil){
            print("pkUserID: \(pkUserID)")
            userApi = ProfileAPIController(delegate: self)
            userApi?.searchPhoto(pkUserID!)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func didReceiveProfileAPIResults(results:NSDictionary){
        
        dispatch_barrier_async(concurrentProfileQueue) {
            let profile: Profile = Profile.profileWithJSON(results);
            dispatch_async(dispatch_get_main_queue(), {
            
                
                /***************** get main profile photo  **************/
                
                //if we have thumb profile picture
                if(profile.urlLarge != ""){
                    // let's download it
                    let imgURL: NSURL! = NSURL(string: profile.urlMedium!)
                    self.url = profile.urlLarge!
                    
                    //let's use haneke 3rd party lib we downloaed
                    self.btnPhoto?.hnk_setBackgroundImageFromURL(imgURL)
                    
                    
                    
                    /*********** 2nd way to upload image from url using native ios asynchronous libraries  ***********/
                    /*
                    // Download an NSData representation of the image at the URL
                    let request: NSURLRequest = NSURLRequest(URL: imgURL)
                    // let urlConnection: NSURLConnection! = NSURLConnection(request: request, delegate: self)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                        if let noerror = data {
                            dispatch_async(dispatch_get_main_queue()) {
                                let image = UIImage(data: noerror)
                                //self.btnPhoto?.setBackgroundImage(image, forState: UIControlState.Normal)
                                self.imgProfilePhoto?.image = image
                            }
                        }
                        else {
                            print("Error: \(error!.localizedDescription)", terminator: "")
                        }
                    })
                    */
                    /************* End of 2nd way of uploading image from url using ios native libs *************/
                    
                    
                /****************** end of get main profile photo  ****************/


                }
                else{
                    //set no photo if there is no profile photo found
                    self.btnPhoto?.setBackgroundImage(UIImage(named:"no-profile-photo"), forState: UIControlState.Normal)
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
            })
        }
    }
    
   
    
    
    @IBAction func goNext(sender: AnyObject) {
        
    }
    
    
    //returned from the zoom screen, empty for now, use it for future
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {}
    /*********************** go to the zoom photo screen *************************/
    @IBAction func doPhotoZoom(sender: AnyObject) {
        //handled in prepareForSegue function below
        performSegueWithIdentifier("zoomProfilePhoto", sender: nil)
    }
    /*********************** end of go to the zoom photo screen *******************/
    
    @IBAction func unwindToThisViewController2(segue: UIStoryboardSegue) {}
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "zoomProfilePhoto" {
            let zoomPhotoViewController: ZoomPhotoViewController = segue.destinationViewController as! ZoomPhotoViewController
            zoomPhotoViewController.url = self.url
            
        }else if segue.identifier == "showFromCamera"{
            let captureProfilePhoto: CaptureProfilePhotoViewController = segue.destinationViewController as! CaptureProfilePhotoViewController
            captureProfilePhoto.launchType = PhotoSource.Camera.description
            
        }else if segue.identifier == "showFromGallery"{
            let captureProfilePhoto: CaptureProfilePhotoViewController = segue.destinationViewController as! CaptureProfilePhotoViewController
            captureProfilePhoto.launchType = PhotoSource.Gallery.description

        }
    }
    

}
