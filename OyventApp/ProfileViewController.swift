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


class ProfileViewController: UIViewController, ProfileAPIControllerProtocol, CLLocationManagerDelegate,ENSideMenuDelegate {

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
 
    @IBOutlet weak var mImageView: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.sideMenuController()?.sideMenu?.delegate = self
        pkUserID = 12
        userApi = ProfileAPIController(delegate: self)
        setupLocationManager()
        setupNavigationBar()
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.hidesBarsOnSwipe = false
        var effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurView = UIVisualEffectView(effect: effect)
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        mImageView.addSubview(blurView)
       
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
        
        println("didUpdateToLocation longitude \(self.latitude)")
        println("didUpdateToLocation latitude \(self.longitude)")
        
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            placemarks, error in
            
            if error == nil && placemarks.count > 0 {
                let placeArray = placemarks as! [CLPlacemark]
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray[0]
                
                // Address dictionary
                println(placeMark.addressDictionary)
                
                // Location name
                if let locationName = placeMark.addressDictionary["Name"] as? NSString {
                    println(locationName)
                }
                
                // Street address
                if let street = placeMark.addressDictionary["Thoroughfare"] as? NSString {
                    println(street)
                }
                
                // City
                if let city = placeMark.addressDictionary["City"] as? NSString {
                    println(city)
                    self.city = city as String
                    self.btnCity.setTitle(city as String, forState: UIControlState.Normal)
                    //to do: initiate the profile info
                    self.userApi?.searchProfile(self.pkUserID)
                    self.locationManager.stopUpdatingLocation()
                }
                
                // Zip code
                if let zip = placeMark.addressDictionary["ZIP"] as? NSString {
                    println(zip)
                }
                
                // Country
                if let country = placeMark.addressDictionary["Country"] as? NSString {
                    println(country)
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
    
    func displayProfileInfo(){
        
    }
    
    func setupNavigationBar(){
        
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.hidesBarsOnSwipe = false
        
        /*********************** left navigation button -> menu image ********************/
        var menuImage:UIImage = UIImage(named: "oyvent-icon-72")!
        menuImage = resizeImage(menuImage,targetSize: CGSize(width: 30, height: 30))
        menuImage = menuImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        var leftButton = UIBarButtonItem(image: menuImage, style: UIBarButtonItemStyle.Plain, target: self, action: "sideMenuClicked")
        self.navigationItem.leftBarButtonItem = leftButton
        /***************** end of navigation left button -> menu image********************/
        
        
        /***************************** navigation title button style  ********************/
        //self.btnAlbum.setTitle("", forState: UIControlState.Normal)
        /***************************** navigation title button style  ********************/
        
        
        /***************** right navigation button -> location image ***********************/
        var locationImage:UIImage = UIImage(named: "location-icon-grey")!
        locationImage = resizeImage(locationImage, targetSize: CGSize(width:30, height:30))
        locationImage = locationImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        var rightButton = UIBarButtonItem(image: locationImage, style: UIBarButtonItemStyle.Plain, target: self, action: "locationClicked")
        self.navigationItem.rightBarButtonItem = rightButton
        /************** end of navigation right button -> location image ********************/
        
        
    }
    
    func locationClicked(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("myNavGeo") as! MyNavigationController
        var geoViewController:GeoViewController =  nvg.topViewController as! GeoViewController
        geoViewController.hasCustomNavigation = true
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = nvg
        appDelegate.window?.makeKeyAndVisible()
    }
    
    
    func sideMenuClicked(){
        toggleSideMenuView()
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        //println("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        //println("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        //println("sideMenuShouldOpenSideMenu")
        return true
    }
    
    /********************* get a transparent background image *******************/
    func onePixelImageWithColor(color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        var context = CGBitmapContextCreate(nil, 1, 1, 8, 0, colorSpace, bitmapInfo)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, 1, 1))
        let image = UIImage(CGImage: CGBitmapContextCreateImage(context))
        return image!
    }/***************** end of get a transparent background image ***************/
    
    
    //
    func didReceiveProfileAPIResults(results:NSDictionary){
        
       dispatch_barrier_async(concurrentProfileQueue) {
        var profile: Profile = Profile.profileWithJSON(results);
            dispatch_async(dispatch_get_main_queue(), {
                //full name
                self.lblFullName.text = profile.fullName
                
                /***************** get main profile photo  **************/
                //set default as no picture
                self.btnPhoto?.setBackgroundImage(UIImage(named:"nopic"), forState: UIControlState.Normal)
                
                //if we have thumb profile picture
                if(profile.urlThumb != ""){
                    // let's download it
                    var imgURL: NSURL! = NSURL(string: profile.urlThumb!)
                    // Download an NSData representation of the image at the URL
                    let request: NSURLRequest = NSURLRequest(URL: imgURL)
                    let urlConnection: NSURLConnection! = NSURLConnection(request: request, delegate: self)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                        if let noerror = data {
                            dispatch_async(dispatch_get_main_queue()) {
                                let image = UIImage(data: noerror)
                                self.btnPhoto?.setBackgroundImage(image, forState: UIControlState.Normal)
                            }
                        }
                        else {
                            println("Error: \(error!.localizedDescription)")
                        }
                    })
                } /****************** get main profile photo  ****************/
                
                
                 UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
