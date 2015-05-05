//
//  MainViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 3/15/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore
import CoreLocation


class HomeViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, PhotoAPIControllerProtocol, ENSideMenuDelegate,  CLLocationManagerDelegate {

    var api:PhotoAPIController?
    var photos:[Photo] = [Photo]()
    let kCellIdentifier: String = "CustomCell"
    var imageCache = [String : UIImage]()
    
    @IBOutlet weak var mTableView: UITableView!
    
    var pageNo:Int = 0
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        println("Returned from detail screen")
    }
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var latitude : String!
    var longitude : String!
    
    var albumID : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        self.locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
                
                currentLocation = locationManager.location
                latitude = "\(currentLocation.coordinate.latitude)"
                longitude = "\(currentLocation.coordinate.longitude)"
                
        }else {
            println("Location services are not enabled");
//            dispatch_async(dispatch_get_main_queue(),{
//                //display alert message with confirmation
//                var myAlert = UIAlertController(title: "Alert", message: "Location services are not enabled", preferredStyle: UIAlertControllerStyle.Alert)
//                let warnAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
//                myAlert.addAction(warnAction)
//                self.presentViewController(myAlert, animated: true, completion: nil)
//            return
//            })
        }
        
    
    
        api = PhotoAPIController(delegate: self)
        //self.mTableView.estimatedRowHeight = 134
        //self.mTableView.rowHeight = UITableViewAutomaticDimension
        //self.view.frame = CGRectMake(0, 0, 320, 1340);
        self.mTableView.frame = CGRectMake(0, 0, 320, 1600);
        //self.mTableView.contentSize = CGSizeMake(320, 1601);
//        self.mTableView.dataSource = self
//        self.mTableView.delegate = self
        //self.mTableView.bounces = true;
        //self.mTableView.pagingEnabled = true
        //self.mTableView.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleHeight
        
//        self.mTableView.scrollEnabled = true
//        var cellHeight  = CGFloat(self.mTableView.rowHeight)
//        var totalCity   = CGFloat(photos.count)
//        var totalHeight = cellHeight * totalCity
//        self.mTableView.frame.size.height = CGFloat(totalHeight)
        
        
        //self.mTableView.setContentOffset(CGPoint(x: 0,y: 134), animated: true)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.albumID = 0
        api!.searchPhotos(pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID)
        
        //let geocoder = CLGeocoder()
        //let locationManager = CLLocationManager()
//        CLLocation.distanceFromLocation(<#CLLocation#>)
        
        
        
        
//        let loc1: CLLocation = CLLocation(latitude: 34.710098, longitude: -92.354525926605)
//        let loc2: CLLocation = CLLocation(latitude: 34.710000, longitude: -92.354525926100)
//        var distance:Double = loc1.distanceFromLocation(loc2)
//        var nf: NSNumberFormatter = NSNumberFormatter()
//        nf.maximumFractionDigits = 2
//        var ds:String  = nf.stringFromNumber(distance)!
//        println("distance: \(ds)")
        
        
        //lat: 34.710098
        //long: -92.354525926605
        
        //lat2 42.692902
       //long2: -73.837923828848
        
        
        
//        let date1 = NSCalendar.currentCalendar().dateWithEra(1, year: 2014, month: 11, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
//        let date2 = NSCalendar.currentCalendar().dateWithEra(1, year: 2015, month: 8, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
        
//        let date1 = NSDate().dateFromString("2015-03-29 18:16:16")
//        let date2:NSDate = NSDate()
//        
//        let years = date2.yearsFrom(date1)     // 0 
//        let months = date2.monthsFrom(date1)   // 9
//        let weeks = date2.weeksFrom(date1)     // 39
//        let days = date2.daysFrom(date1)       // 273
//        let hours = date2.hoursFrom(date1)     // 6,553
//        let minutes = date2.minutesFrom(date1) // 393,180
//        let seconds = date2.secondsFrom(date1) // 23,590,800
//        
//        let timeOffset = date2.offsetFrom(date1) // "9M"
//        println("years=\(years)")
//        println("months=\(months)")
//        println("weeks=\(weeks)")
//        println("days=\(days)")
//        println("hours=\(hours)")
//        println("minutes=\(minutes)")
//        println("seconds=\(seconds)")
//      
//        
//        println("timeOffset=\(timeOffset)")
        
        //self.sideMenuController()?.sideMenu?.delegate = self

        
        setupNavigationBar()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("error to get location : \(error)")
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        currentLocation = newLocation
        
        
        latitude = "\(currentLocation.coordinate.latitude)"
        longitude = "\(currentLocation.coordinate.longitude)"
        println("didUpdateToLocation longitude \(self.latitude)")
        println("didUpdateToLocation latitude \(self.longitude)")
        
        
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
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]  // Title's text color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Camera", style: .Plain, target: self, action: nil)
        
        var menuImage:UIImage = UIImage(named: "oyvent-icon-72")!
        menuImage = resizeImage(menuImage,targetSize: CGSize(width: 40, height: 40))
        menuImage = menuImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        var leftButton = UIBarButtonItem(image: menuImage, style: UIBarButtonItemStyle.Bordered, target: self, action: "sideMenuClicked")
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160
    }
    
    func sideMenuClicked(){
        toggleSideMenuView()
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        println("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        println("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        println("sideMenuShouldOpenSideMenu")
        return true
    }
    
  
    override func viewDidAppear(animated: Bool) {
        self.mTableView!.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println("Photos Count: \(photos.count)")
        return photos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as CustomTableViewCell
       
        let photo:Photo = self.photos[indexPath.row]
        
        let date2:NSDate = NSDate()
        if(photo.postDate != ""){
            let date1:NSDate = NSDate().dateFromString(photo.postDate)
            cell.lblPostDate?.text =  date2.offsetFrom(date1)
        }else{
            cell.lblPostDate?.text = ""
        }
        
        if(photo.createdDate != ""){
            let date3:NSDate = NSDate().dateFromString(photo.createdDate)
            cell.lblCreatedDate?.text = date2.offsetFrom(date3)
        }else{
            cell.lblCreatedDate?.text = ""
        }
        
        cell.lblPkPhotoID?.text = "\(photo.pkPhotoID)"
        cell.lblVoteResult?.text = "\(photo.oy)  oys"
        cell.lblMiles?.text = NSString(format: "%.2f", photo.milesGeo)+" mi"
        cell.btnComments?.setTitle("\(photo.totalComments)", forState: UIControlState.Normal)
        
        if(photo.fkFacebookID != ""){
            cell.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            cell.btnSocial?.setBackgroundImage(UIImage(named: "face-icon-32"), forState: UIControlState.Normal)
            cell.btnSocial?.tintColor=UIColor.blackColor()
        }
        
        if(photo.fkTwitterID != ""){
            cell.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            cell.btnSocial?.setBackgroundImage(UIImage(named: "twitter-icon-32"), forState: UIControlState.Normal)
            cell.btnSocial?.tintColor=UIColor.blackColor()
            
        }
        
        
        if(photo.fkInstagramID != ""){
            cell.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            cell.btnSocial?.setBackgroundImage(UIImage(named: "instagram-icon-32"), forState: UIControlState.Normal)
            cell.btnSocial?.tintColor=UIColor.blackColor()
        }
        
        if(photo.fkInstagramID == "" && photo.fkTwitterID == "" && photo.fkFacebookID == ""){
            cell.btnSocial?.setBackgroundImage(nil, forState: UIControlState.Normal)
        }
        
        if(photo.caption != ""){
            cell.lblCaption?.text = photo.caption
        }else if(photo.ownedBy != ""){
           // cell.lblCaption.font = UIFont(name: cell.lblCaption.font.fontName, size: 11)
           // cell.lblCaption.textColor = UIColor.grayColor()
           cell.lblCaption?.text = "owned by @" + photo.ownedBy
        }else{
            cell.lblCaption?.text = ""
        }
        
//        cell.lblCaption.numberOfLines = 4
//        cell.lblCaption.lineBreakMode = NSLineBreakMode.ByWordWrapping
//        cell.lblCaption.sizeToFit()

        
        
        cell.btnPoster?.setBackgroundImage(UIImage(named:"blank"), forState: UIControlState.Normal)
        //Poster?.image = UIImage(named: "blank")
        cell.lblAlbumName?.text = photo.albumName
        cell.lblFullName?.text = photo.fullName
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        let urlString = photo.smallImageURL
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
                            //println("data:\(image)")
                            // Store the image in to our cache
                            self.imageCache[urlString] = image
                            // cell.imgPoster?.image = image
                            cell.btnPoster?.setBackgroundImage(image, forState: UIControlState.Normal)
                            
                            
//                            let width:CGFloat = self.mTableView.contentSize.width
//                            cell.frame.size  = CGSizeMake(width, 100)
//                            cell.contentView.frame.size = CGSizeMake(width, 100)
//                            cell.layoutIfNeeded()
//                            //view.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.1) // light blue
//                            cell.contentView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.1) // light green
//                            //cell.sizeToFit()
                        }
                    }
                    else {
                        println("Error: \(error.localizedDescription)")
                    }
                })
                
            } else {
                //cell.imgPoster?.image = image
                cell.btnPoster?.setBackgroundImage(image, forState: UIControlState.Normal)
            }
        
       
        return cell
    }
    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        
//        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
//            println("landscape")
//        } else {
//            println("portraight")
//        }
//    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        //cell.contentView.backgroundColor=UIColor.clearColor()
        
        var whiteRoundedCornerView:UIView!
        whiteRoundedCornerView=UIView(frame: CGRectMake(0,cell.frame.height-20,cell.frame.width,20))
        //whiteRoundedCornerView.backgroundColor=UIColor(red: 174/255.0, green: 174/255.0, blue: 174/255.0, alpha: 1.0)
        whiteRoundedCornerView.backgroundColor=UIColor(red: 0.0784314, green: 0.278431, blue: 0.443137, alpha: 0.8) // 0.0784314 0.278431 0.443137 0.8
        //whiteRoundedCornerView.backgroundColor=Optional(UIDeviceRGBColorSpace 0.0784314 0.278431 0.443137 0.8)
        //whiteRoundedCornerView.backgroundColor = UIColor.whiteColor()
        //whiteRoundedCornerView.backgroundColor = UIColor.blackColor()
        whiteRoundedCornerView.layer.masksToBounds=false
        //whiteRoundedCornerView.layer.shadowOpacity = 0.4;
        
        
        
        //        whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(1, 0);
        //whiteRoundedCornerView.layer.shadowColor=UIColor(red: 53/255.0, green: 143/255.0, blue: 185/255.0, alpha: 1.0).CGColor
        
        
        
        //whiteRoundedCornerView.layer.cornerRadius=0.5
        //        whiteRoundedCornerView.layer.shadowOffset=CGSizeMake(-1, -1)
        //        whiteRoundedCornerView.layer.shadowOpacity=0.5
        cell.contentView.addSubview(whiteRoundedCornerView)
        cell.contentView.sendSubviewToBack(whiteRoundedCornerView)
        
        
    }
    

    
    
    @IBAction func doZoom(sender: UIButton) {
        
        var buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.mTableView)
        var indexPath: NSIndexPath = self.mTableView.indexPathForRowAtPoint(buttonPosition)!
        let photo:Photo = self.photos[indexPath.row]
        
//        let zoomController:UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("zoomScrollView") as UIViewController
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.zoomedPhoto = photo
//        appDelegate.window?.rootViewController = zoomController
//        appDelegate.window?.makeKeyAndVisible()
        
        
        performSegueWithIdentifier("zoomSegue", sender: self)
        
    }
    
    
    
    @IBAction func visitSocial(sender: UIButton) {
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
//        UIView.animateWithDuration(0.25, animations: {
//            cell.layer.transform = CATransform3DMakeScale(1,1,1)
//        })
//    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        //println("maximumOffset - currentOffset:\(maximumOffset - currentOffset)")
        
        if (maximumOffset - currentOffset) <= 144 {
            api!.searchPhotos(++pageNo, latitude: self.latitude, longitude: self.longitude, albumID: self.albumID)
        }
    }
    
    func didReceivePhotoAPIResults(results: NSDictionary) {
      
        var resultsArr: [Photo] = results["results"] as [Photo]
        dispatch_async(dispatch_get_main_queue(), {
            if(self.pageNo == 1){
                self.photos = Photo.photosWithJSON(resultsArr)
            }else{
                resultsArr = Photo.photosWithJSON(resultsArr)
                for (var i = 0; i < resultsArr.count; i++) {
                    self.photos.append(resultsArr[i])
                }
            }
            self.mTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
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
