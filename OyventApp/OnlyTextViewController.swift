//
//  OnlyTextViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/25/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit
import CoreLocation

class OnlyTextViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, ENSideMenuDelegate {

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
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnClose2: UIButton!
    
    override func viewDidAppear(animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
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
    
    func setupNavigationBar(){
        
        //        self.navigationController?.navigationBar.hidden = true
        self.navigationController?.hidesBarsOnSwipe = true
        
        
        //self.navigationController?.hidesBarsOnSwipe = true
        //self.navigationController?.hidesBarsOnTap = true // setting hidesBarsOnTap to true
        
        
        
        /***************************** navigation general style  ********************/
        //self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        //self.navigationController?.navigationBar.backgroundColor = bgImageColor
        
        
        //        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]  // Title's text color
        //        //self.navigationController?.navigationBar.tintColor = bgImageColor
        //        UINavigationBar.appearance().barTintColor =  bgImageColor
        //        self.navigationController?.navigationBar.setBackgroundImage(onePixelImageWithColor(bgImageColor),
        //            forBarMetrics: .Default)
        
        
        /***************************** navigation general style  ********************/
        
        
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
        
        
        /***************** right navigation button -> camera image ***********************/
        //        var cameraImage:UIImage = UIImage(named: "camera")!
        //        cameraImage = resizeImage(cameraImage, targetSize: CGSize(width:35, height:35))
        //        cameraImage = cameraImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        //        var rightButton = UIBarButtonItem(image: cameraImage, style: UIBarButtonItemStyle.Bordered, target: self, action: "cameraClicked")
        //        self.navigationItem.rightBarButtonItem = rightButton
        /************** end of navigation right button -> camera image ********************/
        
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
    
    
    @IBAction func shareNow(sender: UIButton) {
        
        var userID: Double = NSUserDefaults.standardUserDefaults().doubleForKey("userID")
        let url = NSURL(string:"http://oyvent.com/ajax/PhotoHandlerWeb.php")
        let request = NSMutableURLRequest(URL: url!)
        let caption = textView.text
        if caption == ""{
            return
        }
        
        
        
        let postString = "processType=UPLOADIOSPHOTOONLYTEXT&albumID=\(albumID)&userID=\(userID)&latitude=\(self.latitude)&longitude=\(self.longitude)&caption=\(caption)"
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
//        println("postString: \(postString)")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error  in
            
            if(error != nil){
                println("error=\(error)")
                return
            }
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers  , error: &err) as? NSDictionary
            
            if let parseJSON = json {
                var resultValue:Bool = parseJSON["success"] as! Bool!
                var error:String? = parseJSON	["error"] as! String?
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    if(!resultValue){
                        //display alert message with confirmation
                        var myAlert = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    }else{
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.textView.text = ""
                        
                        //display alert message with confirmation
                        var myAlert = UIAlertController(title: "Confirmation", message: "Post added successfully!", preferredStyle: UIAlertControllerStyle.Alert)
                        myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                        
                           // self.dismissViewControllerAnimated(true, completion: nil)
                           
                            self.btnClose2.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            
//                            let nvg: MyNavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("myNav") as MyNavigationController
//                            var geoController:GeoViewController =  nvg.topViewController as GeoViewController
//                            geoController.albumID = self.albumID
//                            geoController.albumName = self.albumName
//                            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//                            appDelegate.window?.rootViewController = nvg
//                            appDelegate.window?.makeKeyAndVisible()
                            
                            
                        }))
                        self.presentViewController(myAlert, animated: true, completion: nil)
                        
                    }
                })
            }
        }
        
        task.resume()

        
        
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
        
        //println("didUpdateToLocation longitude \(self.latitude)")
        //println("didUpdateToLocation latitude \(self.longitude)")
        
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            placemarks, error in
            
            if error == nil && placemarks.count > 0 {
                let placeArray = placemarks as! [CLPlacemark]
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray[0]
                
                // City
                if let city = placeMark.addressDictionary["City"] as? NSString {
                    //println(city)
                    self.city = city as String
                    self.albumName = (self.albumID != 0 ) ? self.albumName : self.city
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
