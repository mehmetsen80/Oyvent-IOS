//
//  OnlyTextViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/25/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit
import CoreLocation

class OnlyTextViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate {

    var geoCoder: CLGeocoder!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var latitude : String!
    var longitude : String!
    
    var albumID : Double = 0
    var albumName : String = ""
    var city:String = ""
    
    var placeHolderText = "Enter Text"
    
    @IBOutlet weak var btnAlbumName: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidAppear(animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        btnAlbumName.setTitle(albumName, forState: UIControlState.Normal)
        textView.delegate = self
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doCancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func shareNow(sender: UIButton) {
        println("share now")
    }
    
    
    func setupLocationManager(){
        
        geoCoder = CLGeocoder()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if appDelegate.locManager != nil {
            self.locationManager = appDelegate.locManager!
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
        
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
                
                if self.locationManager.location != nil {
                    currentLocation = self.locationManager.location
                    latitude = "\(currentLocation.coordinate.latitude)"
                    longitude = "\(currentLocation.coordinate.longitude)"
                }
                else{
                    latitude = "0"
                    longitude = "0"
                }
                
        }else {
            println("Location services are not enabled");
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("error to get location : \(error)")
        
        if let clErr = CLError(rawValue: error.code) {
            switch clErr {
            case .LocationUnknown:
                println("location unknown")
            case .Denied:
                println("denied")
            default:
                println("unknown Core Location error")
            }
        } else {
            println("other error")
        }
        
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        currentLocation = newLocation
        self.latitude = "\(currentLocation.coordinate.latitude)"
        self.longitude = "\(currentLocation.coordinate.longitude)"
        
        //println("didUpdateToLocation longitude \(self.latitude)")
        //println("didUpdateToLocation latitude \(self.longitude)")
        
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            placemarks, error in
            
            if error == nil && placemarks.count > 0 {
                let placeArray = placemarks as [CLPlacemark]
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray[0]
                
                // City
                if let city = placeMark.addressDictionary["City"] as? NSString {
                    //println(city)
                    self.city = city
                    self.albumName = (self.albumID != 0 ) ? self.albumName : city
                    self.btnAlbumName.setTitle(self.albumName, forState: UIControlState.Normal)
                    self.locationManager.stopUpdatingLocation()
                    self.locationManager.stopUpdatingLocation()
                }
            }
        })
    }
    
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.textView.textColor = UIColor.blackColor()
        
        if(self.textView.text == placeHolderText) {
            self.textView.text = ""
        }
        
        animateViewMoving(true, moveValue: 225)
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if(textView.text == "") {
            self.textView.text = placeHolderText
            self.textView.textColor = UIColor.lightGrayColor()
        }
        
        animateViewMoving(false, moveValue: 225)
    }
    
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n"
//        {
//            textView.resignFirstResponder()
//            
//            return false
//        }
//        return true
//    }
    
    override func viewWillAppear(animated: Bool) {
        
        //self.textView.becomeFirstResponder()
       
    }
    
    /********* animate add comment textbox either up or down *********/
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }/******* end of animate add comment textbox either up or down *****/

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
