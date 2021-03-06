//
//  MainViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 3/15/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit
import CoreLocation
import Haneke

class GroupsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate , AlbumAPIControllerProtocol,  CLLocationManagerDelegate {

    var api:AlbumAPIController?
    var albums:[Album] = [Album]()
    @IBOutlet weak var mCollectionView: UICollectionView!
    let kCellIdentifier: String = "groupsCell"
    var pageNo:Int = 0
    let bgImageColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    var loadSpinner:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    @IBOutlet weak var btnCity: UIButton!
    @IBOutlet weak var lblFooter: UILabel!

    let colors = Colors()
    
    //location
    var geoCoder: CLGeocoder!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var latitude : String!
    var longitude : String!
    var city:String = ""
    
    var imageCache = [String : UIImage]()
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var selectedAlbum : Album!
    
    private let concurrentAlbumQueue = dispatch_queue_create(
        "com.oy.vent.albumQueue", DISPATCH_QUEUE_CONCURRENT)
    
    var hasCustomNavigation: Bool = false

    
    override func viewDidAppear(animated: Bool) {
        
        
        
        //to do:
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: 0) as HomeCollectionViewCell
//        cell.btnGeoAlbum.setTitle(self.city, forState: UIControlState.Normal)
//        cell.imgPoster?.image = UIImage(named: "location-icon")
        
       
       
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        pageNo = 0
        imageCache = [String : UIImage]()
        albums = [Album]()
        
        api = AlbumAPIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      
        
        setupLocationManager()
        
        //load more spinner
        self.loadSpinner.center = self.mCollectionView.center
        self.loadSpinner.frame = CGRectMake((self.mCollectionView.frame.width-10)/2 , -10, 10, 10);
        self.loadSpinner.hidesWhenStopped = true
        self.mCollectionView.addSubview(self.loadSpinner)
        
        //get the screen sizes
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        

    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
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
                
                // City
                if let city = placeMark.addressDictionary?["City"] as? NSString {
                    print(city, terminator: "")
                    self.city = city as String
                    self.btnCity.setTitle(city as String, forState: UIControlState.Normal)
                    //self.api!.searchAllAlbums(0, latitude: self.latitude, longitude: self.longitude, pkAlbumID: self.selectedAlbum.pkAlbumID)
                    self.api!.searchAllAlbums(0, latitude: self.latitude, longitude: self.longitude, pkAlbumID: 34)
                    
                    //self.albums.append(Album(pkAlbumID: -1, albumName: self.city))//initial city cell
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
    
    func collectionView(collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            
        var header: GroupsHeaderCollectionReusableView?
        var footer: GroupsFooterCollectionReusableView?
        
            if kind == UICollectionElementKindSectionHeader {
                header =
                    collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                        withReuseIdentifier: "MyHeader", forIndexPath: indexPath)
                    as? GroupsHeaderCollectionReusableView
                
                header?.btnHeader.setTitle("Select a Category", forState: UIControlState.Normal)
                //header?.btnHeader.setBackgroundImage(onePixelImageWithColor(bgImageColor), forState: UIControlState.Normal)
                
                return header!
            } else if kind == UICollectionElementKindSectionFooter {
             
                footer =
                    collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                        withReuseIdentifier: "MyFooter", forIndexPath: indexPath)
                    as? GroupsFooterCollectionReusableView
                
                footer?.lblFooter.text = "Total \(albums.count) Categories"
                
                return footer!
                
            }
        
            return header!
    }
   
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: indexPath) as! GroupsCollectionViewCell
        
        let album:Album = self.albums[indexPath.row]
        
        //cell.backgroundColor = UIColor.blackColor()
        //cell.btnGeoAlbum.setTitle(album.albumName, forState: UIControlState.Normal)
        //cell.btnGeoAlbum.setBackgroundImage(onePixelImageWithColor(bgImageColor), forState: UIControlState.Normal)
        
        cell.btnGeoAlbum.setBackgroundImage(self.getCategoryImage(album.fkCategoryID!), forState: UIControlState.Normal)
        
        
        //cell.btnGeoAlbum?.setBackgroundImage(onePixelImageWithColor(bgImageColor), forState: UIControlState.Normal)
        //cell.imgPoster?.image = (indexPath.row==0) ? UIImage(named: "city") : UIImage(named: "location-icon")
        
        //parentName
        if(album.fkParentID==0){
            cell.btnParentName.setTitle(album.albumName! + " (\(album.totalPhotoSize!))", forState: UIControlState.Normal)
            cell.lblCategoryName.hidden = true
            
        }else{
            cell.btnParentName.setTitle(album.parentName, forState: UIControlState.Normal)
        }
        cell.btnParentName.setBackgroundImage(onePixelImageWithColor(bgImageColor), forState: UIControlState.Normal)
        
        //category Name
        cell.lblCategoryName.text = "\(album.albumName!) (\(album.photoSize!))"
        
        

        /********************************** Big Poster *********************************/
        
        //println("album.fkCategoryID: \(album.fkCategoryID!)")
        
        let ctgID = album.fkCategoryID!
        print("Category Name: \(album.albumName)  Category ID: \(album.fkCategoryID)", terminator: "")
        
        if(ctgID == 0){ //parent category
       
        
            cell.imgPoster?.image = UIImage(named:"blank")
            //get the image
            let urlString: String? = album.urlMedium
            if(urlString != ""){
                let image = self.imageCache[urlString!]
                if(image == nil) {
            
                    // If the image does not exist, we need to download it
                    let imgURL: NSURL! = NSURL(string: urlString!)
                    
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
                                self.imageCache[urlString!] = image
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
            }
        }
        else{//child category
            
           //cell.imgPoster?.image = self.getCategoryImage(album.fkCategoryID!)
            //cell.imgPoster?.image = UIImage(named: ("ctg-dining"))!

        }
            
        
        /********************************** End of Big Poster ***************************/
        //cell.imgPoster?.hidden = false
        
        
        //enable this if needed
        //cell.lblMiles?.text = (indexPath.row==0) ? "Main City" : "\(album.milesUser) miles"
        if(album.fkParentID == 0){
            cell.lblMiles?.text = "\(album.milesUser!) miles"
            cell.lblMiles.hidden = false
        }
        
        
       
//        cell.backgroundColor = UIColor.clearColor()
//        var backgroundLayer = colors.gl
//        backgroundLayer.frame = cell.layer.bounds
//        let backgroundView = UIView(frame: cell.layer.bounds)
//        cell.layer.insertSublayer(backgroundLayer, atIndex: 0)
//        cell.backgroundView = backgroundView
        
        
        
        cell.backgroundColor = UIColor(red: 0x00/255, green: 0x50/255, blue: 0x7d/255, alpha: 0.8)
        cell.layer.cornerRadius = 12.0
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor(red: 0xcc/255, green: 0xcc/255, blue: 0xcc/255, alpha: 1.0).CGColor

        
        return cell
    }
    
   
    
    func getCategoryImage(catagoryID: Double) -> UIImage{
        
        var categoryPoster = UIImage(named:"blank")
        
        switch (catagoryID){
        case 2:
            categoryPoster = UIImage(named: "ctg-coffee")
        case 3:
            categoryPoster = UIImage(named: "ctg-parking")
        case 4:
            categoryPoster = UIImage(named: "ctg-dining")
        case 5:
            categoryPoster = UIImage(named: "ctg-greek")
        case 6:
            categoryPoster = UIImage(named: "ctg-shopping")
        case 7:
            categoryPoster = UIImage(named: "ctg-sports")
        case 8:
            categoryPoster = UIImage(named: "ctg-studentservices")
        case 9:
            categoryPoster = UIImage(named: "ctg-housing")
        case 10:
            categoryPoster = UIImage(named: "ctg-police")
        case 11:
            categoryPoster = UIImage(named: "ctg-class")
        default:
            categoryPoster = UIImage(named: "ctg-general") //categoryID = 1
            
        }
        
        return categoryPoster!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(10, 10, 10, 10); //top,left,bottom,right
    }

   
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    
    
    func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            
            let album:Album = self.albums[indexPath.row]
            //println("albumName: \(album.albumName!) albumpkID: \(album.pkAlbumID!)")
            
            ///self.performSegueWithIdentifier("gotoGeo", sender: indexPath)
            
            /**********************************************************************************/
            // get tabBarController, then UINavigationBar, then ViewController, update ViewController and finally select 1st tabItem
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let mainTabBar : UITabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("mainTabBar") as! UITabBarController
            let nvg: UINavigationController = mainTabBar.viewControllers![0] as! UINavigationController
            let geoView:GeoViewController =  nvg.topViewController as! GeoViewController
            geoView.albumID = album.pkAlbumID!
            geoView.albumName = album.albumName!
            geoView.fkParentID = album.fkParentID!
            geoView.parentName = album.parentName!
            geoView.scrollToTop()  //it breaks when tab changes
            mainTabBar.selectedIndex = 0
            appDelegate.window?.rootViewController = mainTabBar
            appDelegate.window?.makeKeyAndVisible()
            /**********************************************************************************/
            
            //println("shouldSelectItemAtIndexPath: \(indexPath.row)")
            return false
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
       
        let album:Album = self.albums[indexPath.row]
        
        //println("albumName: \(album.albumName)  screenWidth: \(screenWidth)  screenHeight: \(screenHeight)")
        
        return (album.fkParentID == 0) ? CGSize(width: screenWidth, height: screenWidth/2.5) : CGSize(width: (screenWidth-40)/2, height: screenWidth/2.5)
         //return  CGSize(width: (screenWidth-40)/2, height: screenWidth/2)
        //return  CGSize(width: screenWidth, height: 140)
    }
    
    @IBAction func doVisitAlbum(sender: DefaultButton) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.mCollectionView)
         let indexPath: NSIndexPath = self.mCollectionView!.indexPathForItemAtPoint(buttonPosition)!
        //var indexPath: NSIndexPath = self.mCollectionView.indexPathForRowAtPoint(buttonPosition)!
        let album:Album = self.albums[indexPath.row]
        //self.performSegueWithIdentifier("gotoGeo", sender: indexPath)
        
        
        
        /**********************************************************************************/
        // get tabBarController, then UINavigationBar, then ViewController, update ViewController and finally select 1st tabItem
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mainTabBar : UITabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("mainTabBar") as! UITabBarController
        let nvg: UINavigationController = mainTabBar.viewControllers![0] as! UINavigationController
        let geoView:GeoViewController =  nvg.topViewController as! GeoViewController
        geoView.albumID = album.pkAlbumID!
        geoView.albumName = album.albumName!
        geoView.fkParentID = album.fkParentID!
        geoView.parentName = album.parentName!
        geoView.scrollToTop()  //it breaks when tab changes
        mainTabBar.selectedIndex = 0
        appDelegate.window?.rootViewController = mainTabBar
        appDelegate.window?.makeKeyAndVisible()
        /**********************************************************************************/
        
        
        
        
    }
    
    
    @IBAction func doVisitCity(sender: UIButton) {
        print("doVisityCity()", terminator: "")
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        print("currentOffset: \(currentOffset)  maximumOffset: \(maximumOffset)")
//        if(currentOffset <  -100) {
//            //println("currentOffset>maximumOffset ->  currentOffset: \(currentOffset)  maximumOffset: \(maximumOffset)")
//            self.loadSpinner.startAnimating()
//            self.albums = []
//            self.albums.append(Album(pkAlbumID: -1, albumName: self.city))
//            api!.searchAlbums(0, latitude: self.latitude, longitude: self.longitude)
//        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        //println("maximumOffset \(maximumOffset)  currentOffset: \(currentOffset)")
        if (maximumOffset - currentOffset) <= 144  &&  maximumOffset > 0{
            //println("let's search: maximumOffset - currentOffset:\(maximumOffset - currentOffset)")
            //api!.searchAllAlbums(++pageNo, latitude: self.latitude, longitude: self.longitude, pkAlbumID: self.selectedAlbum.pkAlbumID)
        }
    }
    
    func didReceiveAlbumAPIResults(results: NSDictionary) {
        
        dispatch_barrier_async(concurrentAlbumQueue) {
            var resultsArr: [Album] = results["results"] as! [Album]
            dispatch_async(dispatch_get_main_queue(), {
                
                resultsArr = Album.albumsWithJSON(resultsArr)
                for (var i = 0; i < resultsArr.count; i++) {
                    self.albums.append(resultsArr[i])
                }
                
                
                self.mCollectionView!.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.loadSpinner.stopAnimating()
            })
            
        }
    }
  
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "gotoGeo"{
            //let geoViewController:GeoViewController =  segue.destinationViewController as GeoViewController
            //var myNavController: MyNavigationController = segue.destinationViewController as! MyNavigationController
            let nvg: UINavigationController = segue.destinationViewController as! UINavigationController
            let geoViewController: GeoViewController =  nvg.topViewController as! GeoViewController
            //let geoViewController:GeoViewController = segue.destinationViewController as! GeoViewController
            geoViewController.hasCustomNavigation = false
            let indexPath : NSIndexPath = sender as! NSIndexPath
            
            //let indexPaths : NSArray = self.mCollectionView.indexPathsForSelectedItems()!
     
            //println(indexPath)
            let selectedAlbum = self.albums[indexPath.row]
            print("albumName: \(selectedAlbum.albumName!) pkAlbumID: \(selectedAlbum.pkAlbumID!)", terminator: "")
            geoViewController.albumID = selectedAlbum.pkAlbumID!
            geoViewController.albumName = selectedAlbum.albumName!
            geoViewController.fkParentID = selectedAlbum.fkParentID!
            geoViewController.parentName = selectedAlbum.parentName!
        }else if segue.identifier == "jumptoGeo"{
            
        }
        
    }
    

}
