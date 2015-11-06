//
//  ProfileViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 7/25/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore
import CoreLocation


class ProfileViewController: UIViewController, ProfileAPIControllerProtocol, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate{

    var userApi:ProfileAPIController?
    private let concurrentProfileQueue = dispatch_queue_create(
        "com.oy.vent.profileQueue", DISPATCH_QUEUE_CONCURRENT)
    //location
    var geoCoder: CLGeocoder!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var latitude : String!
    var longitude : String!
    var city:String = ""
    @IBOutlet weak var btnCity: UIButton!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var btnPhoto: UIButton!
    var pkUserID : Double!
    var fullname : String!
 
    @IBOutlet weak var mImageView: UILabel!
    var url : String!
    
    override func viewDidAppear(animated: Bool) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        pkUserID =  NSNumberFormatter().numberFromString(NSUserDefaults.standardUserDefaults().stringForKey("userID")!)?.doubleValue
        fullname = NSUserDefaults.standardUserDefaults().stringForKey("fullname")!
        
        //just for test, to do: remove this later
        pkUserID = 11111
        
        userApi = ProfileAPIController(delegate: self)
        setupLocationManager()
        //setupNavigationBar()
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.hidesBarsOnSwipe = false
        //self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
//        self.navigationController?.navigationBar.backgroundColor = UIColor.blackColor()
//        let effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//        let blurView = UIVisualEffectView(effect: effect)
//        blurView.translatesAutoresizingMaskIntoConstraints = false
//        mImageView.addSubview(blurView)
        
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLocationManager(){
        
        geoCoder = CLGeocoder()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.locManager != nil {
            self.locationManager = appDelegate.locManager!
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
        
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
                
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
            print("Location services are not enabled", terminator: "");
        }
    }

    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error to get location : \(error)", terminator: "")
        
        if let clErr = CLError(rawValue: error.code) {
            switch clErr {
            case .LocationUnknown:
                print("location unknown", terminator: "")
            case .Denied:
                print("denied", terminator: "")
            default:
                print("unknown Core Location error", terminator: "")
            }
        } else {
            print("other error", terminator: "")
        }
        
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        currentLocation = newLocation
        self.latitude = "\(currentLocation.coordinate.latitude)"
        self.longitude = "\(currentLocation.coordinate.longitude)"
        
        print("didUpdateToLocation longitude \(self.latitude)", terminator: "")
        print("didUpdateToLocation latitude \(self.longitude)", terminator: "")
        
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            placemarks, error in
            
            if error == nil && placemarks!.count > 0 {
                let placeArray = placemarks as [CLPlacemark]?
                // Place details
                let placeMark: CLPlacemark! = placeArray?[0]
                // Address dictionary
                //print(placeMark.addressDictionary, terminator: "")
                
                
                // City
                if let city = placeMark.addressDictionary?["City"] as? NSString {
                    print(city, terminator: "")
                    self.city = city as String
                    self.btnCity.setTitle(city as String, forState: UIControlState.Normal)
                    //to do: initiate the profile info
                    self.userApi?.searchPhoto(self.pkUserID)
                    self.locationManager.stopUpdatingLocation()
                }
                
               
                
            }
        })
        
        
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    //returned from the zoom screen, empty for now, use it for future
    @IBAction func unwindFromSelectPhotoToThisViewController(segue: UIStoryboardSegue) {}
    
    
    func displayProfileInfo(){
        
    }
    
    func setupNavigationBar(){
        
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.hidesBarsOnSwipe = false
        
        /*********************** left navigation button -> menu image ********************/
        var menuImage:UIImage = UIImage(named: "oyvent-icon-72")!
        menuImage = resizeImage(menuImage,targetSize: CGSize(width: 30, height: 30))
        menuImage = menuImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let leftButton = UIBarButtonItem(image: menuImage, style: UIBarButtonItemStyle.Plain, target: self, action: "sideMenuClicked")
        self.navigationItem.leftBarButtonItem = leftButton
        /***************** end of navigation left button -> menu image********************/
        
        
        /***************************** navigation title button style  ********************/
        //self.btnAlbum.setTitle("", forState: UIControlState.Normal)
        /***************************** navigation title button style  ********************/
        
        
        /***************** right navigation button -> location image ***********************/
        var locationImage:UIImage = UIImage(named: "location-icon-grey")!
        locationImage = resizeImage(locationImage, targetSize: CGSize(width:30, height:30))
        locationImage = locationImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let rightButton = UIBarButtonItem(image: locationImage, style: UIBarButtonItemStyle.Plain, target: self, action: "locationClicked")
        self.navigationItem.rightBarButtonItem = rightButton
        /************** end of navigation right button -> location image ********************/
        
        
    }
    
    func locationClicked(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("myNavGeo") as! MyNavigationController
        let geoViewController:GeoViewController =  nvg.topViewController as! GeoViewController
        geoViewController.hasCustomNavigation = true
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = nvg
        appDelegate.window?.makeKeyAndVisible()
    }
    
    
    
    /********************* get a transparent background image *******************/
    func onePixelImageWithColor(color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(nil, 1, 1, 8, 0, colorSpace, bitmapInfo.rawValue)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, 1, 1))
        let image = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
        return image
    }/***************** end of get a transparent background image ***************/
    
    //returned from the profile update photo screen
    @IBAction func unwindFromProfilePhotoUpdateToThisViewController(segue: UIStoryboardSegue) {}
    
    //returned from the zoom screen, empty for now, use it for future
    @IBAction func unwindFromZoomScreenToThisViewController(segue: UIStoryboardSegue) {}
     /*********************** go to the zoom photo screen *************************/
    @IBAction func selectProfilePhoto(sender: CircleButton) {
        
        //zoom photo
        if self.url != ""{
            let photoZoomView: ZoomPhotoViewController = self.storyboard!.instantiateViewControllerWithIdentifier("photoZoomView") as! ZoomPhotoViewController
            photoZoomView.url = self.url
           self.presentViewController(photoZoomView, animated:true, completion:nil)
            
        }else{//select photo type
            let selectPhotoType: SelectPhotoViewController = self.storyboard!.instantiateViewControllerWithIdentifier("selectPhotoTypeView") as! SelectPhotoViewController
            selectPhotoType.modalPresentationStyle = .Popover
            selectPhotoType.preferredContentSize = CGSizeMake(180.0, 90.0)
            selectPhotoType.popoverPresentationController!.delegate = self
            selectPhotoType.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection.Any
            selectPhotoType.popoverPresentationController!.sourceView = sender
            selectPhotoType.popoverPresentationController!.sourceRect = sender.bounds
            self.presentViewController(selectPhotoType, animated:true, completion:nil)
        }
    }
    /*********************** end of go to the zoom photo screen *******************/
    
    //
    func didReceiveProfileAPIResults(results:NSDictionary){
       
       
        
       dispatch_barrier_async(concurrentProfileQueue) {
        let profile: Profile = Profile.profileWithJSON(results);
            dispatch_async(dispatch_get_main_queue(), {
                //full name
                //self.lblFullName.text = profile.fullName
                self.lblFullName.text = self.fullname
                
                
                /***************** get main profile photo  **************/
                //if we have thumb profile picture
                if(profile.urlMedium != "" || profile.urlMedium != nil){
                    // let's download it
                    let imgURL: NSURL! = NSURL(string: profile.urlMedium!)
                    self.url = profile.urlLarge!
                    //let's use haneke 3rd party lib we download
                    self.btnPhoto?.hnk_setBackgroundImageFromURL(imgURL)
                    
                    
                    // Download an NSData representation of the image at the URL
                    /*
                    let request: NSURLRequest = NSURLRequest(URL: imgURL)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                        if let noerror = data {
                            dispatch_async(dispatch_get_main_queue()) {
                                let image = UIImage(data: noerror)
                                self.btnPhoto?.setBackgroundImage(image, forState: UIControlState.Normal)
                                self.url = profile.urlLarge!
                            }
                        }
                        else {
                            print("Error: \(error!.localizedDescription)", terminator: "")
                        }
                    })
                    */
                    
                   
                    
                }
                else{
                    //set no photo if there is no profile photo found
                    self.btnPhoto?.setBackgroundImage(UIImage(named:"no-profile-photo"), forState: UIControlState.Normal)
                   
                }
                 /****************** get main profile photo  ****************/
                
                
                 UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
            })
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "zoomProfilePhoto" {
            let zoomPhotoViewController: ZoomPhotoViewController = segue.destinationViewController as! ZoomPhotoViewController
            zoomPhotoViewController.url = self.url
        }else if(segue.identifier == "selectPhotoType"){
            let selectPhotoType: SelectPhotoViewController = self.storyboard!.instantiateViewControllerWithIdentifier("selectPhotoTypeView") as! SelectPhotoViewController
            selectPhotoType.modalPresentationStyle = .Popover
            //selectPhotoType.preferredContentSize = CGSizeMake(180.0, 90.0)
            selectPhotoType.popoverPresentationController!.delegate = self
            selectPhotoType.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection.Any
          //  selectPhotoType.popoverPresentationController!.sourceView = sender
            //selectPhotoType.popoverPresentationController!.sourceRect = sender.frame
        }
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    

}
