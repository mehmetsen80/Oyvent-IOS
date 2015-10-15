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
import Haneke

class GeoViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate,PhotoAPIControllerProtocol, GeoTableHeaderViewCellDelegate,  UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, UITabBarDelegate{

    var api:PhotoAPIController?
    var photos:[Photo] = [Photo]()
    let kCellIdentifier: String = "GeoCell"
    var imageCache = [String : UIImage]()
    var pageNo:Int = 0
    var city:String = ""
    @IBOutlet weak var mTableView: UITableView!
    let bgImageColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
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
    var fkParentID : Double = 0
    var parentName : String = ""
    
    var hasCustomNavigation: Bool = false
    
    
    func scrollToTop() {
       
        let top = NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0);
        print("scrollToTop() \(top)", terminator: "")
        if(self.mTableView != nil){
            print("scrollToTop() \(UIApplication.sharedApplication().statusBarFrame.height)", terminator: "")
            self.mTableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: true);
            self.mTableView!.reloadData()
            self.mTableView.setContentOffset(CGPointMake(0,  UIApplication.sharedApplication().statusBarFrame.height ), animated: true)
        }else{
            print("self.mTableView is nil", terminator: "")
        }
        //println("photos size:  \(photos.count)  pageNo: \(pageNo)")
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
                
                print("latitude: \(latitude)  longitude: \(longitude)")
                
        }else {
            print("Location services are not enabled", terminator: "");
        }
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print("didSelectItem", terminator: "")
        
        switch item.tag {
        
        case 0:
            print("hey", terminator: "")
            scrollToTop()
            break
        case 1:
                print("item.tag: \(item.tag)", terminator: "")
            break
        case 2:
                print("item.tag: \(item.tag)", terminator: "")
            break
            
        default:
            break;
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
    
        //self.navigationController?.hidesBarsOnSwipe = true
        //self.navigationController?.hidesBarsOnTap = true // setting hidesBarsOnTap to true
        
        /***************************** navigation general style  ********************/
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]  // Title's text color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        /***************************** navigation general style  ********************/
        
        
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
        //this block also works
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//        let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("navGeo") as! MyNavigationController
//        let geoController:GeoViewController =  nvg.topViewController as! GeoViewController
//        geoController.hasCustomNavigation = true
//        sideMenuController()?.setContentViewController(geoController)
//        sideMenuController()?.sideMenu?.hideSideMenu()
        
        
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("myNavGeo") as! MyNavigationController
        //let geoViewController:GeoViewController =  nvg.topViewController as! GeoViewController
        //geoViewController.hasCustomNavigation = true
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = nvg
        appDelegate.window?.makeKeyAndVisible()

    }
//    
//    func sideMenuClicked(){
//        toggleSideMenuView()
//    }
//    
//    // MARK: - ENSideMenu Delegate
//    func sideMenuWillOpen() {
//        //println("sideMenuWillOpen")
//    }
//    
//    func sideMenuWillClose() {
//        //println("sideMenuWillClose")
//    }
//    
//    func sideMenuShouldOpenSideMenu() -> Bool {
//        //println("sideMenuShouldOpenSideMenu")
//        return true
//    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear()  pageNo: \(pageNo)", terminator: "")
        
        setupLocationManager();
        
        //self.sideMenuController()?.sideMenu?.delegate = self
        
        api = PhotoAPIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.mTableView.layer.cornerRadius=5;
        self.loadSpinner.center = self.mTableView.center
        self.loadSpinner.frame = CGRectMake((self.mTableView.frame.width-10)/2 , -10, 10, 10);
        self.loadSpinner.hidesWhenStopped = true
        self.mTableView.addSubview(self.loadSpinner)
        self.navigationController!.navigationBar.hidden = false
        
        //self.btnGeoAlbum?.setBackgroundImage(onePixelImageWithColor(bgImageColor), forState: UIControlState.Normal)
        
//        if(hasCustomNavigation){
//            setupNavigationBar()
//        }
        
        //self.navigationController?.navigationBar.hidden = false
        //self.navigationController?.hidesBarsOnSwipe = false
        
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController!.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //println("viewDidLoad()")
        //setupNavigationBar()
        self.navigationController!.navigationBar.hidden = false
    }
    
    

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
       
    }
    
    @IBAction func doResetPosts(sender: UIButton) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.albumID = 0
//        self.btnGeoAlbum.setTitle(self.city, forState: UIControlState.Normal)
        self.pageNo=0
        self.fkParentID=0
        self.photos = []
        scrollToTop()
        api!.searchPhotos(pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID,fkParentID: self.fkParentID)
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
        
        //println("didUpdateToLocation longitude \(self.latitude)")
        //println("didUpdateToLocation latitude \(self.longitude)")
        
        
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) -> Void  in
            
            if error == nil && placemarks!.count > 0 {
                let placeArray = placemarks as [CLPlacemark]?
                // Place details
                let placeMark: CLPlacemark! = placeArray?[0]
                
                // City
                if let city = placeMark.addressDictionary?["City"] as? NSString {
                    //println(city)
                    
                    self.city = city as String
                    self.btnCity.setTitle(city as String, forState: UIControlState.Normal)
                    self.api!.searchPhotos(0, latitude: self.latitude, longitude: self.longitude, albumID:  self.albumID, fkParentID: self.fkParentID)
                    self.albumName = (self.albumID != 0 ) ? self.albumName : "Near Me"
//                    self.btnGeoAlbum.setTitle(self.albumName, forState: UIControlState.Normal)
                    self.locationManager.stopUpdatingLocation()
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
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(nil, 1, 1, 8, 0, colorSpace, bitmapInfo.rawValue)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, 1, 1))
        let image = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
        return image
    }/***************** end of get a transparent background image ***************/
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! GeoTableViewCell
        let photo:Photo = self.photos[indexPath.row]
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false
        
        
        
        /********************************** Big Poster *********************************/
        cell.imgPoster?.image = UIImage(named:"blank")
        
        //get the image
        let urlString = photo.mediumImageURL
        let image = self.imageCache[urlString]
        if(image == nil) {
            
            
            // If the image does not exist, we need to download it
            let imgURL: NSURL! = NSURL(string: urlString)
            
            //haneke
            cell.imgPoster?.hnk_setImageFromURL(imgURL)
            
            
            // Download an NSData representation of the image at the URL
            /*let request: NSURLRequest = NSURLRequest(URL: imgURL)
            let urlConnection: NSURLConnection! = NSURLConnection(request: request, delegate: self)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if let noerror = data {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        image = UIImage(data: noerror)
                        // Store the image in to our cache
                        self.imageCache[urlString] = image
                        cell.imgPoster?.image = image
                    }
                }
                else {
                    println("Error: \(error!.localizedDescription)")
                }
            })*/
            
        } else {
            cell.imgPoster?.image = image
        }
        /********************************** End of Big Poster ***************************/
        
        
        
        /************************ album Name should less than 37 chars ***********************/
        let albumName = photo.albumName
        if(albumName.characters.count>37){
            cell.btnGeoAlbum?.setTitle(albumName.substringToIndex(albumName.startIndex.advancedBy(37))+"..." , forState: UIControlState.Normal)
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
        
        
        
        /************************ other inputs  ******************************/
        cell.lblCaption?.text = photo.caption
        cell.lblFullName?.text = photo.fullName
        cell.lblPostDate?.text = (photo.postDate != "") ? NSDate().offsetFrom(NSDate().dateFromString(photo.postDate)) : "" //get the post date in days,minutes,month,year
        
        let miles = self.albumID == 0 ? photo.milesUser : photo.milesGeo
        cell.lblMilesGeo?.text = (NSString(format: "%.2f", miles) as String) + " mi"
        /********************* End of other inputs  ***************************/
        
        
        /**************************** pick up the right social button ************************/
        if(photo.fkFacebookID != ""){//facebook social button
            cell.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            cell.btnSocial?.setBackgroundImage(UIImage(named: "face-icon-32"), forState: UIControlState.Normal)
            cell.btnSocial?.tintColor=UIColor.blackColor()
            cell.lblFullName?.text = photo.ownedBy
            
        }
        if(photo.fkTwitterID != ""){//twitter social button
            cell.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            cell.btnSocial?.setBackgroundImage(UIImage(named: "twitter-icon-32"), forState: UIControlState.Normal)
            cell.btnSocial?.tintColor=UIColor.blackColor()
            cell.lblFullName?.text = photo.ownedBy
        }
        if(photo.fkInstagramID != ""){//instagram social button
            cell.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            cell.btnSocial?.setBackgroundImage(UIImage(named: "instagram-icon-32"), forState: UIControlState.Normal)
            cell.btnSocial?.tintColor=UIColor.blackColor()
            cell.lblFullName?.text = photo.ownedBy
        }
        //if no social button, then clear the background of social button
        if(photo.fkInstagramID == "" && photo.fkTwitterID == "" && photo.fkFacebookID == ""){
            cell.btnSocial?.setBackgroundImage(nil, forState: UIControlState.Normal)
        }
        /********************* End of pick up the right social button ************************/
        
        
        
       
        
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get the row data for the selected row
        self.performSegueWithIdentifier("detailsView", sender: indexPath)
    }
    
    func didSelectGeoTableHeaderViewCell(Selected: Bool, GeoHeader: GeoTableHeaderCell) {
      
        pageNo=0
        self.photos = []
        self.imageCache = [String : UIImage]()
        scrollToTop()
        api!.searchPhotos(pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID, fkParentID: self.fkParentID)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        
        let header = tableView.dequeueReusableCellWithIdentifier("GeoHeader") as! GeoTableHeaderCell
        header.delegate = self
        
        header.btnGeoAlbum.setTitle(self.albumName, forState: UIControlState.Normal)
        /********************************** Main Album Button *********************************/
       header.btnGeoAlbum?.setBackgroundImage(UIImage(named:"blank"), forState: UIControlState.Normal)
       //get the image
       let urlString = "https://s3-oy-vent-images-14.s3.amazonaws.com/58/04674bd29a28422c-medium.jpg"

        // If the image does not exist, we need to download it
        let imgURL: NSURL! = NSURL(string: urlString)

        // Download an NSData representation of the image at the URL
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        //let urlConnection: NSURLConnection! = NSURLConnection(request: request, delegate: self)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
            
                    dispatch_async(dispatch_get_main_queue()) {
                        //let image = UIImage(data: noerror)
                        //let image = UIImage(named: "bgred")
                        //header.btnGeoAlbum?.setBackgroundImage(image, forState: UIControlState.Normal)
                        
                        //enable this background if needed
                        header.btnGeoAlbum?.setBackgroundImage(self.onePixelImageWithColor(self.bgImageColor), forState: UIControlState.Normal)
                            header.lblParentName.text = self.parentName
                    }
                
        })
        
        /***************************** End of Main Album Button ***************************/
        
        
        //header.contentView.backgroundColor = UIColor.whiteColor()
        return header
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
    
    @IBAction func visitDetailsView(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.mTableView)
        let indexPath: NSIndexPath = self.mTableView.indexPathForRowAtPoint(buttonPosition)!
        self.performSegueWithIdentifier("detailsView", sender: indexPath)
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        //println("currentOffset: \(currentOffset)  maximumOffset: \(maximumOffset)")
        if(currentOffset <  -100) {
            print("currentOffset>maximumOffset ->  currentOffset: \(currentOffset)  maximumOffset: \(maximumOffset)", terminator: "")
            self.loadSpinner.startAnimating()
            pageNo=0
            api!.searchPhotos(pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID, fkParentID: self.fkParentID)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        print("maximumOffset \(maximumOffset)  currentOffset: \(currentOffset)", terminator: "")
        if (maximumOffset - currentOffset) <= 144  &&  maximumOffset > 0{
            print("let's search: maximumOffset - currentOffset:\(maximumOffset - currentOffset)", terminator: "")
            api!.searchPhotos(++pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID,fkParentID: self.fkParentID)
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
        let cell = self.mTableView.cellForRowAtIndexPath(indexPath) as! GeoTableViewCell
        let photo:Photo = self.photos[indexPath.row]
        let pkPhotoID:String = NSString(format: "%.0f", photo.pkPhotoID) as String
        let userID:String = NSUserDefaults.standardUserDefaults().stringForKey("userID")!
        let url = NSURL(string:"http://oyvent.com/ajax/Album.php")
        let request = NSMutableURLRequest(URL: url!)
        let postString = "processType=\(voteType)&pkPhotoID=\(pkPhotoID)&userID=\(userID)"
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error  in
            
            if(error != nil){
                print("error=\(error)", terminator: "")
                return
            }
            
            //var err: NSError?
            do{
            let parseJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers  ) as? NSDictionary
            
            
                let resultValue:Bool = parseJSON?["success"] as! Bool!
                let message:String? = parseJSON?["message"] as! String?
                let already:Bool = parseJSON?["already"] as! Bool!
            
                dispatch_async(dispatch_get_main_queue(),{
                    if(!resultValue){
                        //display alert message with error
                        let myAlert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.Alert)
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
            } catch{
                
            }
            
            
        }
        
        task.resume()
    }
    /*********************************** end of vote up or down ****************************/
    
    
    @IBAction func doVisitSocial(sender: AnyObject) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.mTableView)
        let indexPath: NSIndexPath = self.mTableView.indexPathForRowAtPoint(buttonPosition)!
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
        var resultsArr: [Photo] = results["results"] as! [Photo]
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
        print("welcome back to GeoViewController!", terminator: "")
        
    }
    
    @IBAction func unwindToThisViewController2(segue: UIStoryboardSegue) {
        print("welcome back to GeoViewController unwind2!", terminator: "")
        
        pageNo=0
        self.photos = []
        self.imageCache = [String : UIImage]()
        scrollToTop()
        api!.searchPhotos(pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID, fkParentID: self.fkParentID)
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
            let detailsViewController: DetailsViewController = segue.destinationViewController as! DetailsViewController
            let photoIndex = self.mTableView!.indexPathForSelectedRow!.row
            let selectedPhoto = self.photos[photoIndex]
            detailsViewController.photo = selectedPhoto
        }
            //else if segue.identifier == "captureView" {
//            var captureViewController: CaptureViewController = segue.destinationViewController as CaptureViewController
//            captureViewController.albumID = self.albumID
//            captureViewController.albumName = self.albumName
//        }
            else if segue.identifier == "selectCategory" {
            let categoryViewController: CategoryViewController = segue.destinationViewController as! CategoryViewController
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
