//
//  GeoViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 4/8/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore
import CoreLocation

class GeoViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate,PhotoAPIControllerProtocol, GeoTableHeaderViewCellDelegate, ENSideMenuDelegate,  UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate{

    var api:PhotoAPIController?
    var photos:[Photo] = [Photo]()
    let kCellIdentifier: String = "GeoCell"
    var imageCache = [String : UIImage]()
    var pageNo:Int = 0
    var city:String = ""
    @IBOutlet weak var mTableView: UITableView!
    let bgImageColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
    var loadSpinner:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    @IBOutlet weak var btnGeoAlbum: UIButton!
    private let concurrentPhotoQueue = dispatch_queue_create(
        "com.oy.vent.photoQueue", DISPATCH_QUEUE_CONCURRENT)
    
    @IBOutlet weak var btnCity: UIButton!
    var geoCoder: CLGeocoder!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var latitude : String!
    var longitude : String!
    
    var albumID : Double = 0
    var albumName : String = ""
    
    
    
    func scrollToTop() {
        var top = NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0);
        if(self.mTableView != nil){
            self.mTableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: true);
            self.mTableView!.reloadData()
            self.mTableView.setContentOffset(CGPointMake(0,  UIApplication.sharedApplication().statusBarFrame.height ), animated: true)
        }
        //println("photos size:  \(photos.count)  pageNo: \(pageNo)")
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
        var leftButton = UIBarButtonItem(image: menuImage, style: UIBarButtonItemStyle.Bordered, target: self, action: "sideMenuClicked")
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
    
   
    
    func cameraClicked(){
        //println("cameraClicked");
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
    
    override func viewDidAppear(animated: Bool) {
        println("viewDidAppear()  pageNo: \(pageNo)")
        
        setupLocationManager();
        
        self.sideMenuController()?.sideMenu?.delegate = self
        
        api = PhotoAPIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.mTableView.layer.cornerRadius=5;
        self.loadSpinner.center = self.mTableView.center
        self.loadSpinner.frame = CGRectMake((self.mTableView.frame.width-10)/2 , -10, 10, 10);
        self.loadSpinner.hidesWhenStopped = true
        self.mTableView.addSubview(self.loadSpinner)
        //self.btnGeoAlbum?.setBackgroundImage(onePixelImageWithColor(bgImageColor), forState: UIControlState.Normal)
        

        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //println("viewDidLoad()")
        setupNavigationBar()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
       
    }
    
    @IBAction func doResetPosts(sender: UIButton) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.albumID = 0
//        self.btnGeoAlbum.setTitle(self.city, forState: UIControlState.Normal)
        self.pageNo=0
        self.photos = []
        scrollToTop()
        api!.searchPhotos(pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID)
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
                
                // Address dictionary
                //println(placeMark.addressDictionary)
                
                // Location name
                if let locationName = placeMark.addressDictionary["Name"] as? NSString {
                    //println(locationName)
                }
                
                // Street address
                if let street = placeMark.addressDictionary["Thoroughfare"] as? NSString {
                    //println(street)
                }
                
                // City
                if let city = placeMark.addressDictionary["City"] as? NSString {
                    //println(city)
                    
                    self.city = city
                    self.btnCity.setTitle(city, forState: UIControlState.Normal)
                    self.api!.searchPhotos(0, latitude: self.latitude, longitude: self.longitude, albumID:  self.albumID)
                    self.albumName = (self.albumID != 0 ) ? self.albumName : "General"
//                    self.btnGeoAlbum.setTitle(self.albumName, forState: UIControlState.Normal)
                    self.locationManager.stopUpdatingLocation()
                }
                
                // Zip code
                if let zip = placeMark.addressDictionary["ZIP"] as? NSString {
                    //println(zip)
                }
                
                // Country
                if let country = placeMark.addressDictionary["Country"] as? NSString {
                    //println(country)
                }
                
                
                
            }
        })
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 355
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
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as GeoTableViewCell
        let photo:Photo = self.photos[indexPath.row]
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false
        
        
        
        /********************************** Big Poster *********************************/
        cell.imgPoster?.image = UIImage(named:"blank")
        //get the image
        let urlString = photo.mediumImageURL
        var image = self.imageCache[urlString]
        if(image == nil) {
            
            // If the image does not exist, we need to download it
            var imgURL: NSURL! = NSURL(string: urlString)
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            let urlConnection: NSURLConnection! = NSURLConnection(request: request, delegate: self)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if !(error? != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        image = UIImage(data: data)
                        // Store the image in to our cache
                        self.imageCache[urlString] = image
                        cell.imgPoster?.image = image
                    }
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
            
        } else {
            cell.imgPoster?.image = image
        }
        /********************************** End of Big Poster ***************************/
        
        
        
        /************************ album Name should less than 37 chars ***********************/
        let albumName = photo.albumName
        if(countElements(albumName)>37){
            cell.btnGeoAlbum?.setTitle(albumName.substringToIndex(advance(albumName.startIndex, 37))+"..." , forState: UIControlState.Normal)
        }else{
            cell.btnGeoAlbum?.setTitle(albumName, forState: UIControlState.Normal)
        }
        cell.btnGeoAlbum?.setBackgroundImage(onePixelImageWithColor(bgImageColor), forState: UIControlState.Normal)
        /********************************** End of Album Name ********************************/
        
        
        
        /*********************************** Comment Box with Size ***************************/
        if(photo.totalComments==0){
            cell.btnComments?.hidden = true
        }else{
            cell.btnComments?.hidden = false
            cell.btnComments?.setTitle("\(photo.totalComments)", forState: UIControlState.Normal)
        }
        /**************************** End of Comment Box with Size ***************************/
        
        
        /**************** user has already voted, then disable vote buttons **************/
        cell.btnVoteUp.enabled = !photo.hasVoted
        cell.btnVoteDown.enabled = !photo.hasVoted
        cell.lblOys?.text = (photo.oy <= 0) ? "\(photo.oy) oys" : "+\(photo.oy) oys"
        /************************************ end of votes ********************************/
        
        
        
        /**************************** pick up the right social button ************************/
        if(photo.fkFacebookID != ""){//facebook social button
            cell.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            cell.btnSocial?.setBackgroundImage(UIImage(named: "face-icon-32"), forState: UIControlState.Normal)
            cell.btnSocial?.tintColor=UIColor.blackColor()
        }
        if(photo.fkTwitterID != ""){//twitter social button
            cell.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            cell.btnSocial?.setBackgroundImage(UIImage(named: "twitter-icon-32"), forState: UIControlState.Normal)
            cell.btnSocial?.tintColor=UIColor.blackColor()
        }
        if(photo.fkInstagramID != ""){//instagram social button
            cell.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            cell.btnSocial?.setBackgroundImage(UIImage(named: "instagram-icon-32"), forState: UIControlState.Normal)
            cell.btnSocial?.tintColor=UIColor.blackColor()
        }
        //if no social button, then clear the background of social button
        if(photo.fkInstagramID == "" && photo.fkTwitterID == "" && photo.fkFacebookID == ""){
            cell.btnSocial?.setBackgroundImage(nil, forState: UIControlState.Normal)
        }
        /********************* End of pick up the right social button ************************/
        
        
        
        /************************ other inputs  ******************************/
        cell.lblCaption?.text = photo.caption
        cell.lblFullName?.text = photo.fullName
        cell.lblPostDate?.text = (photo.postDate != "") ? NSDate().offsetFrom(NSDate().dateFromString(photo.postDate)) : "" //get the post date in days,minutes,month,year
        cell.lblMilesGeo?.text = NSString(format: "%.2f", photo.milesUser) + " mi"
        /********************* End of other inputs  ***************************/
        
        return cell

    }
    
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
        var whiteRoundedCornerView:UIView!
        whiteRoundedCornerView=UIView(frame: CGRectMake(0,cell.frame.height-20,cell.frame.width,20))
        //whiteRoundedCornerView.backgroundColor=UIColor(red: 0.0784314, green: 0.278431, blue: 0.443137, alpha: 0.8) // 0.0784314 0.278431 0.443137 0.8
        whiteRoundedCornerView.backgroundColor = UIColor.whiteColor()
        whiteRoundedCornerView.layer.masksToBounds=false
        cell.contentView.addSubview(whiteRoundedCornerView)
        cell.contentView.sendSubviewToBack(whiteRoundedCornerView)
    }
    
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        var v: UIView = UIView()
//        v.backgroundColor = UIColor.clearColor()
//        return v
//    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        // Get the row data for the selected row
        self.performSegueWithIdentifier("detailsView", sender: indexPath)
    }
    
    func didSelectGeoTableHeaderViewCell(Selected: Bool, GeoHeader: GeoTableHeaderCell) {
      
        pageNo=0
        self.photos = []
        self.imageCache = [String : UIImage]()
        scrollToTop()
        api!.searchPhotos(pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView
    {
        
        var header = tableView.dequeueReusableCellWithIdentifier("GeoHeader") as GeoTableHeaderCell
        header.delegate = self
        
        header.btnGeoAlbum.setTitle(self.albumName, forState: UIControlState.Normal)
        /********************************** Main Album Button *********************************/
       header.btnGeoAlbum?.setBackgroundImage(UIImage(named:"blank"), forState: UIControlState.Normal)
       //get the image
       let urlString = "https://s3-oy-vent-images-14.s3.amazonaws.com/58/04674bd29a28422c-medium.jpg"

        // If the image does not exist, we need to download it
        var imgURL: NSURL! = NSURL(string: urlString)

        // Download an NSData representation of the image at the URL
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        let urlConnection: NSURLConnection! = NSURLConnection(request: request, delegate: self)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if !(error? != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        let image = UIImage(data: data)
                        //header.btnGeoAlbum?.setBackgroundImage(image, forState: UIControlState.Normal)
                        header.btnGeoAlbum?.setBackgroundImage(self.onePixelImageWithColor(self.bgImageColor), forState: UIControlState.Normal)
                    }
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
        })
        
        /***************************** End of Main Album Button ***************************/
        
        
        //header.contentView.backgroundColor = UIColor.whiteColor()
        return header
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    @IBAction func visitDetailsView(sender: UIButton) {
        var buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.mTableView)
        var indexPath: NSIndexPath = self.mTableView.indexPathForRowAtPoint(buttonPosition)!
        self.performSegueWithIdentifier("detailsView", sender: indexPath)
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        //println("currentOffset: \(currentOffset)  maximumOffset: \(maximumOffset)")
        if(currentOffset <  -100) {
            println("currentOffset>maximumOffset ->  currentOffset: \(currentOffset)  maximumOffset: \(maximumOffset)")
            self.loadSpinner.startAnimating()
            pageNo=0
            api!.searchPhotos(pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        println("maximumOffset \(maximumOffset)  currentOffset: \(currentOffset)")
        if (maximumOffset - currentOffset) <= 144  &&  maximumOffset > 0{
            println("let's search: maximumOffset - currentOffset:\(maximumOffset - currentOffset)")
            api!.searchPhotos(++pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID)
        }
        
      
        
//        //frame Optional((0.0,20.0,320.0,44.0))
//        let frame: CGRect? = self.navigationController?.navigationBar.frame;
//        println("frame \(frame)")
//        
//        if(self.lastContentOffset >= currentOffset ){//Scroll Direction Down
//            self.navigationController?.navigationBar.hidden = false
//            self.navigationController?.navigationBar.frame = CGRect(x: 0.0, y: 20.0, width: 320, height: 44)
//        }else{
//        
//            //self.navigationController?.navigationBar.frame.size.height = 0.0 // frame = CGRect(x: 0.0, y: 20.0, width: 320, height: 0)
//            self.navigationController?.navigationBar.hidden = true
//           
//        }
//        
//    
//        if(self.lastContentOffset>=currentOffset ){//scroll down
//            self.navigationController?.navigationBar.hidden = false
//        }else{
//            self.navigationController?.navigationBar.hidden = true
//        }
//        self.lastContentOffset = scrollView.contentOffset.y - 0.1;

        
    }
    
   
   
    
    /*************************************** vote positive **********************************/
    @IBAction func doVoteUp(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.mTableView)
        let indexPath: NSIndexPath = self.mTableView.indexPathForRowAtPoint(buttonPosition)!
        vote(indexPath, voteType: "VOTEUP")
    }/************************************* end of vote positive ****************************/
    
    
    /**************************************** vote negative *********************************/
    @IBAction func doVoteDown(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.mTableView)
        let indexPath: NSIndexPath = self.mTableView.indexPathForRowAtPoint(buttonPosition)!
        vote(indexPath, voteType: "VOTEDOWN")
    }/************************************* end of vote negative ****************************/
    
    
    /************************************** vote up or down *******************************/
    func vote(indexPath: NSIndexPath, voteType: String){
        let cell = self.mTableView.cellForRowAtIndexPath(indexPath) as GeoTableViewCell
        let photo:Photo = self.photos[indexPath.row]
        let pkPhotoID:String = NSString(format: "%.0f", photo.pkPhotoID)
        let userID:String = NSUserDefaults.standardUserDefaults().stringForKey("userID")!
        let url = NSURL(string:"http://oyvent.com/ajax/Album.php")
        let request = NSMutableURLRequest(URL: url!)
        let postString = "processType=\(voteType)&pkPhotoID=\(pkPhotoID)&userID=\(userID)"
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error  in
            
            if(error != nil){
                println("error=\(error)")
                return
            }
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers  , error: &err) as? NSDictionary
            
            if let parseJSON = json {
                let resultValue:Bool = parseJSON["success"] as Bool!
                let message:String? = parseJSON	["message"] as String?
                let already:Bool = parseJSON["already"] as Bool!
            
                dispatch_async(dispatch_get_main_queue(),{
                    if(!resultValue){
                        //display alert message with error
                        var myAlert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    }else{
                        
                        if(!already){
                            cell.btnVoteUp.enabled = false
                            cell.btnVoteDown.enabled = false
                            cell.lblOys.text = message
                        }
                    }
                })
            }
            
            
        }
        
        task.resume()
    }
    /*********************************** end of vote up or down ****************************/
    
    
    @IBAction func doVisitSocial(sender: AnyObject) {
        var buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.mTableView)
        var indexPath: NSIndexPath = self.mTableView.indexPathForRowAtPoint(buttonPosition)!
        let photo:Photo = self.photos[indexPath.row]
        self.openUrl(photo.contentLink)
    }
    
    func openUrl(url:String!) {
        if let url = NSURL(string: url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
  

    func didReceivePhotoAPIResults(results: NSDictionary) {
        
        dispatch_barrier_async(concurrentPhotoQueue) {
        var resultsArr: [Photo] = results["results"] as [Photo]
        dispatch_async(dispatch_get_main_queue(), {
          
            resultsArr = Photo.photosWithJSON(resultsArr)
            for (var i = 0; i < resultsArr.count; i++) {
                self.photos.append(resultsArr[i])
            }
            
            self.mTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.loadSpinner.stopAnimating()
        })
            
       }
    }

    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        println("welcome back!")
    }
    
    
 
    
   
    @IBAction func filterByAlbumID(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.mTableView)
        let indexPath: NSIndexPath = self.mTableView.indexPathForRowAtPoint(buttonPosition)!
        let photo:Photo = self.photos[indexPath.row]
        

        
        //println("fkAlbumID: \(photo.fkAlbumID)")
        //println("albumName: \(photo.albumName)")
        self.albumID = photo.fkAlbumID
//        self.btnGeoAlbum.setTitle(photo.albumName, forState: UIControlState.Normal)
        pageNo=0
        self.photos = []
        scrollToTop()
        //api!.searchPhotos(pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID)
        
    }
    
    
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "detailsView" {
            var detailsViewController: DetailsViewController = segue.destinationViewController as DetailsViewController
            let photoIndex = self.mTableView!.indexPathForSelectedRow()!.row
            let selectedPhoto = self.photos[photoIndex]
            detailsViewController.photo = selectedPhoto
        }
            //else if segue.identifier == "captureView" {
//            var captureViewController: CaptureViewController = segue.destinationViewController as CaptureViewController
//            captureViewController.albumID = self.albumID
//            captureViewController.albumName = self.albumName
//        }
            else if segue.identifier == "selectCategory" {
            var categoryViewController: CategoryViewController = segue.destinationViewController as CategoryViewController
            //categoryViewController.preferredContentSize = CGSizeMake(500,600)
            categoryViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            categoryViewController.popoverPresentationController!.delegate = self
            categoryViewController.albumID = self.albumID
            categoryViewController.albumName = self.albumName
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    

}
