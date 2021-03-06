//
//  CategoriesViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 6/7/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,ENSideMenuDelegate, AlbumAPIControllerProtocol, CLLocationManagerDelegate {

    @IBOutlet weak var mCollectionView: UICollectionView!
    let kCellIdentifier: String = "mainCell"
    var api:AlbumAPIController?
    var pageNo:Int = 0
    var albums:[Album] = [Album]()
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    let bgImageColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
    var loadSpinner:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    @IBOutlet weak var btnCity: UIButton!
    
    //geo related
    var geoCoder: CLGeocoder!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var latitude : String!
    var longitude : String!
    var city:String = ""
    var imageCache = [String : UIImage]()
    

    
    
    private let concurrentAlbumQueue = dispatch_queue_create(
        "com.oy.vent.parentAlbumQueue", DISPATCH_QUEUE_CONCURRENT)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        api = AlbumAPIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.sideMenuController()?.sideMenu?.delegate = self
        setupLocationManager();
        
        //load more spinner
        self.loadSpinner.center = self.mCollectionView.center
        self.loadSpinner.frame = CGRectMake((self.mCollectionView.frame.width-10)/2 , -10, 10, 10);
        self.loadSpinner.hidesWhenStopped = true
        self.mCollectionView.addSubview(self.loadSpinner)
        
        //get the screen sizes
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        
        //setupNavigationBar()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        setupNavigationBar()
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
                    self.btnCity.setTitle(self.city, forState: UIControlState.Normal)
                    self.api!.searchParentAlbums(0, latitude: self.latitude, longitude: self.longitude)
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
    
    func setupNavigationBar(){
        
        //self.navigationController?.hidesBarsOnTap = true
        //self.navigationController?.hidesBarsOnSwipe = true
        
        /***************************** navigation general style  ********************/
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]  // Title's text color
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
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
        //Present new view controller
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//        let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("myGeoNav") as MyNavigationController
//        let geoController:GeoViewController =  nvg.topViewController as GeoViewController
//        geoController.hasCustomNavigation = true
//        sideMenuController()?.setContentViewController(geoController)
//        sideMenuController()?.sideMenu?.hideSideMenu()
        
        //self.performSegueWithIdentifier("jumptoGeo", sender: nil)//not used anymore
        
        
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("myNavGeo") as! MyNavigationController
        let geoViewController:GeoViewController =  nvg.topViewController as! GeoViewController
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

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        var header: MainCollectionReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            header =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "mainHeader", forIndexPath: indexPath)
                as? MainCollectionReusableView
            
            header?.lblMainHeader.text = "Groups Near By"
          
        }
        return header!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: indexPath) as! MainCollectionViewCell
        
        
        let album:Album = self.albums[indexPath.row]
        //cell.backgroundColor = UIColor.blackColor()
        cell.btnParent.setTitle(album.albumName, forState: UIControlState.Normal)
        cell.btnParent.setBackgroundImage(onePixelImageWithColor(bgImageColor), forState: UIControlState.Normal)
        
        
        if(album.fkParentID == 0){
            cell.lblMiles?.text = "\(album.milesUser!) miles"
            cell.lblMiles.hidden = false
        }
        
        cell.lblPhotoSize.text = "(\(album.totalPhotoSize!) posts)"
        
        
        cell.imgPoster?.image = UIImage(named:"blank")
        //get the image
        let urlString: String? = album.urlMedium
        if(urlString != "" && urlString != nil){
            var image = self.imageCache[urlString!]
            if(image == nil) {
                
                // If the image does not exist, we need to download it
                let imgURL: NSURL? = NSURL(string: urlString!)
                
                if let url = imgURL{
                
                // Download an NSData representation of the image at the URL
                let request: NSURLRequest = NSURLRequest(URL: url)
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
                        print("Error: \(error!.localizedDescription)", terminator: "")
                    }
                })
                    
                }
                
            } else {
                cell.imgPoster?.image = image
            }
        }

        
        
        
//        cell.layer.cornerRadius = 12.0
//        cell.layer.shadowColor = UIColor.darkGrayColor().CGColor
//        cell.layer.shadowOffset = CGSizeMake(5, 5.0);
//        cell.layer.shadowRadius = 12.0
//        cell.layer.shadowOpacity = 1.0
//        cell.layer.masksToBounds = true
//        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.contentView.bounds, cornerRadius: 12).CGPath
        
        
        
        cell.backgroundColor = UIColor(red: 0xff/255, green: 0xff/255, blue: 0xff/255, alpha: 1.0)//00507d
        cell.layer.cornerRadius = 12.0
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor(red: 0xcc/255, green: 0xcc/255, blue: 0xcc/255, alpha: 1.0).CGColor

        
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  albums.count
    }
    
    @IBAction func doVisitHome(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.mCollectionView)
        let indexPath: NSIndexPath = self.mCollectionView!.indexPathForItemAtPoint(buttonPosition)!
        //var indexPath: NSIndexPath = self.mCollectionView.indexPathForRowAtPoint(buttonPosition)!
        let album:Album = self.albums[indexPath.row]
        
        //To do: fix this
        //self.performSegueWithIdentifier("gotoHome", sender: indexPath)
        
        
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("myCategoryFeedNav") as! MyNavigationController
        let groupsViewController:GroupsViewController =  nvg.topViewController as! GroupsViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        print("albumName: \(album.albumName!) pkAlbumID: \(album.pkAlbumID!)", terminator: "")
        groupsViewController.selectedAlbum = album
        appDelegate.window?.rootViewController = nvg
        appDelegate.window?.makeKeyAndVisible()
        
    }
    
    //this is actually not triggered right now
    func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            let album:Album = self.albums[indexPath.row]
            //self.performSegueWithIdentifier("gotoHome", sender: indexPath)
 
            
            return false
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        //return  CGSize(width: (screenWidth-40), height: (screenWidth/2)-40)
        return  CGSize(width: (screenWidth-40), height: 160)
        
        //return  CGSize(width: screenWidth, height: 140)
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        //println("maximumOffset \(maximumOffset)  currentOffset: \(currentOffset)")
        if (maximumOffset - currentOffset) <= 144  &&  maximumOffset > 0{
            //println("let's search: maximumOffset - currentOffset:\(maximumOffset - currentOffset)")
            //api!.searchAlbums(++pageNo, latitude: self.latitude, longitude: self.longitude)
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
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        
//        
//        if segue.identifier == "gotoHome"{
//            //let geoViewController:GeoViewController =  segue.destinationViewController as GeoViewController
//            //var myNavController: MyNavigationController = segue.destinationViewController as! MyNavigationController
//            //let homeViewController:HomeViewController =  myNavController.topViewController as! HomeViewController
//            //sideMenuController()?.setContentViewController(homeViewController)
//            let homeViewController:HomeViewController = segue.destinationViewController as! HomeViewController
//            let indexPath : NSIndexPath = sender as! NSIndexPath
//            let indexPaths : NSArray = self.mCollectionView.indexPathsForSelectedItems()
//            
//            //println(indexPath)
//            var selectedAlbum = self.albums[indexPath.row]
//            println("albumName: \(selectedAlbum.albumName!) pkAlbumID: \(selectedAlbum.pkAlbumID!)")
//            homeViewController.selectedAlbum = selectedAlbum
//           
//        }
//        
//    }


}
