//
//  DetailsViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 4/8/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit
import CoreLocation

class DetailsViewController: UIViewController, CommentAPIControllerProtocol, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate{
 
    var api:CommentAPIController?
    var photo:Photo!
    var comments:[Comment] = [Comment]()
    let kCellIdentifier: String = "DetailsCell"
    private let concurrentCommentQueue = dispatch_queue_create(
        "com.oy.vent.commentQueue", DISPATCH_QUEUE_CONCURRENT)
    let bgImageColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
    
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var btnGeoAlbum: UIButton!
    @IBOutlet weak var btnBigPoster: UIButton!
    @IBOutlet weak var lblMiles: UILabel!
    @IBOutlet weak var lblOys: UILabel!
    @IBOutlet weak var btnVoteUp: UIButton!
    @IBOutlet weak var btnVoteDown: UIButton!
    @IBOutlet weak var btnSocial: UIButton!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var txtMessage: UITextField!
    
    var geoCoder: CLGeocoder!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var latitude : Double!
    var longitude : Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocationManager()
        self.mTableView.rowHeight = UITableViewAutomaticDimension
        self.mTableView.estimatedRowHeight = 57
        self.api = CommentAPIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.api?.searchPhotos(photo.pkPhotoID)
        
        
        
        
        /********************************** Big Poster *********************************/
        var blankimage = UIImage(named:"blank")
        self.btnBigPoster?.setBackgroundImage(blankimage, forState: UIControlState.Normal)
        let urlString: String = photo.mediumImageURL//get the image
        var imgURL: NSURL! = NSURL(string: urlString)
        let request: NSURLRequest = NSURLRequest(URL: imgURL)// Download an NSData representation of the image at the URL
        let urlConnection: NSURLConnection! = NSURLConnection(request: request, delegate: self)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if !(error? != nil) {
                dispatch_async(dispatch_get_main_queue()) {
                    var image = UIImage(data: data)
                    self.btnBigPoster?.setBackgroundImage(image, forState: UIControlState.Normal)
                }
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        /********************************** End of Big Poster ***************************/
            
        
       
        /************************ album Name should less than 37 chars ***********************/
        let albumName = self.photo.albumName
        if(countElements(albumName)>37){
            self.btnGeoAlbum?.setTitle(albumName.substringToIndex(advance(albumName.startIndex, 37))+"..." , forState: UIControlState.Normal)
        }else{
            self.btnGeoAlbum?.setTitle(albumName, forState: UIControlState.Normal)
        }
        self.btnGeoAlbum?.setBackgroundImage(onePixelImageWithColor(bgImageColor), forState: UIControlState.Normal)
        /********************************** End of Album Name ********************************/
        
        
        
        
        /**************** user has already voted, then disable vote buttons **************/
        self.btnVoteUp.enabled = !photo.hasVoted
        self.btnVoteDown.enabled = !photo.hasVoted
        self.lblOys?.text = (photo.oy <= 0) ? "\(photo.oy) oys" : "+\(photo.oy) oys"
        /************************************ end of votes ********************************/
        
        
        
        
        /**************************** pick up the right social button ************************/
        if(photo.fkFacebookID != ""){//facebook social button
            self.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            self.btnSocial?.setBackgroundImage(UIImage(named: "face-icon-32"), forState: UIControlState.Normal)
            self.btnSocial?.tintColor=UIColor.blackColor()
        }
        if(photo.fkTwitterID != ""){//twitter social button
            self.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            self.btnSocial?.setBackgroundImage(UIImage(named: "twitter-icon-32"), forState: UIControlState.Normal)
            self.btnSocial?.tintColor=UIColor.blackColor()
            
        }
        if(photo.fkInstagramID != ""){//instagram social button
            self.btnSocial?.frame =  CGRect(x:0, y:0, width: 10, height: 10)
            self.btnSocial?.setBackgroundImage(UIImage(named: "instagram-icon-32"), forState: UIControlState.Normal)
            self.btnSocial?.tintColor=UIColor.blackColor()
        }
        //if no social button, then clear the background of social button
        if(photo.fkInstagramID == "" && photo.fkTwitterID == "" && photo.fkFacebookID == ""){
            self.btnSocial?.setBackgroundImage(nil, forState: UIControlState.Normal)
        }
        /********************* End of pick up the right social button ************************/

        
        
        
        /************************ other inputs  ******************************/
        self.lblMiles?.text = NSString(format: "%.2f", photo.milesUser)+" mi" //miles of user
        self.lblFullName?.text = photo.fullName //fullname of the user
        self.lblPostDate?.text = (photo.postDate != "") ? NSDate().offsetFrom(NSDate().dateFromString(photo.postDate)) : "" //get the post date in days,minutes,month,year
        /********************* End of other inputs  ***************************/
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
                    latitude = currentLocation.coordinate.latitude
                    longitude = currentLocation.coordinate.longitude
                }
                else{
                    latitude = 0
                    longitude = 0
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
        self.latitude = currentLocation.coordinate.latitude
        self.longitude = currentLocation.coordinate.longitude
        
        println("didUpdateToLocation longitude \(self.latitude)")
        println("didUpdateToLocation latitude \(self.longitude)")
        
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            placemarks, error in
            
            if error == nil && placemarks.count > 0 {
                let placeArray = placemarks as [CLPlacemark]
                
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
    
    
    
    @IBAction func doVoteUp(sender: UIButton) {
        vote("VOTEUP")
    }
    
    @IBAction func doVoteDown(sender: UIButton) {
        vote("VOTEDOWN")
    }
    
    func vote(voteType: String){
        let pkPhotoID:String = NSString(format: "%.0f", photo.pkPhotoID)
        var userID:String = NSUserDefaults.standardUserDefaults().stringForKey("userID")!
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
                var resultValue:Bool = parseJSON["success"] as Bool!
                var message:String? = parseJSON	["message"] as String?
                var already:Bool = parseJSON["already"] as Bool!
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    if(!resultValue){
                        //display alert message with confirmation
                        var myAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    }else{
                        
                        if(!already){
                            self.btnVoteUp.enabled = false
                            self.btnVoteDown.enabled = false
                            self.lblOys.text = message
                        }
                    }
                    
                })
                
            }
            
        }
        
        task.resume()
    }
    
    


    
    @IBAction func doVisitSocial(sender: UIButton) {
        self.openUrl(photo.contentLink)
    }
    
    func openUrl(url:String!) {
        
        if let url = NSURL(string: url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func onePixelImageWithColor(color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        var context = CGBitmapContextCreate(nil, 1, 1, 8, 0, colorSpace, bitmapInfo)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, 1, 1))
        let image = UIImage(CGImage: CGBitmapContextCreateImage(context))
        return image!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as DetailsTableViewCell
        let comment:Comment = self.comments[indexPath.row]
        cell.btnUser.setTitle(comment.fullName, forState: UIControlState.Normal)
        cell.lblComment.text = comment.message
        cell.lblPostDate?.text = (comment.postDate != "" && comment.postDate != nil) ? NSDate().offsetFrom(NSDate().dateFromString(comment.postDate!)) : "" //get the post date in days,minutes,month,year
        if self.latitude != nil && self.longitude != nil && comment.latitude != nil && comment.longitude != nil {
            let loc1: CLLocation = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
            let loc2: CLLocation = CLLocation(latitude: comment.latitude!, longitude: comment.longitude!)
            var milesUser = (loc1.distanceFromLocation(loc2)/1000) * 0.621371
            milesUser = round(milesUser * (pow(10.0, 2.0))) / (pow(10.0, 2.0))
            cell.lblMilesUser.text =  "\(milesUser) mi"
        }
        return cell
    }
    
    func scrollToTop() {
        var top = NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0);
        if(self.mTableView != nil){
            self.mTableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: true);
            self.mTableView!.reloadData()
        }
    }
    
    
    @IBAction func textFieldDidBeginEditing(sender: AnyObject) {
        animateViewMoving(true, moveValue: 225)
        println("textFieldDidBeginEditing")
    }
    
    
    @IBAction func textFieldDidEndOnExit(sender: AnyObject) {
    }
    
    @IBAction func textFieldDidEndEditing(sender: AnyObject) {
        animateViewMoving(false, moveValue: 225)
        println("textFieldDidEndEditing")
    }
   
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    

    @IBAction func doAddComment(sender: RoundButton) {
        
        var userID:String = NSUserDefaults.standardUserDefaults().stringForKey("userID")!
        let url = NSURL(string:"http://oyvent.com/ajax/Feeds.php")
        let request = NSMutableURLRequest(URL: url!)
        let comment = self.txtMessage.text
        
        if comment == ""{
            return
        }
        
        let postString = "processType=ADDCOMMENT&photoID=\(photo.pkPhotoID)&userID=\(userID)&ownername=\(photo.fullName)&owneremail=\(photo.email)&latitude=\(self.latitude)&longitude=\(self.longitude)&comment=\(comment)"
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
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
                var resultValue:Bool = parseJSON["success"] as Bool!
                var error:String? = parseJSON	["error"] as String?
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    if(!resultValue){
                        //display alert message with confirmation
                        var myAlert = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    }else{
                        self.api?.searchPhotos(self.photo.pkPhotoID)
                        self.txtMessage.text = ""
                        self.view.endEditing(true);
                        self.scrollToTop()
                    }
                    
                })
                
            }
            
        }
        
        task.resume()
    }
    
    
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        println("Returned from detail screen")
    }

    @IBAction func doZoom(sender: UIButton) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.zoomedPhoto = photo
            appDelegate.window?.makeKeyAndVisible()
        performSegueWithIdentifier("zoomPoster", sender: self)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveCommentAPIResults(results: NSDictionary) {
        
        dispatch_barrier_async(concurrentCommentQueue) {
           // var resultsArr: [Comment] = []
            var resultsArr: [Comment]  = results["results"] as [Comment]
            self.comments = []
            dispatch_async(dispatch_get_main_queue(), {
                
                
                //get the total retrieved comments from db into an array
                resultsArr = Comment.commentsWithJSON(resultsArr)
                //before comment manipulation, first add the caption as the first comment
                if(self.photo.caption != ""){
                    self.comments.append(Comment(fullName: "Caption by " + self.photo.fullName,message: self.photo.caption))
                    self.lblComments.text = "Comments (\(self.comments.count))"
                }
                
                //we are ready to pump the comments into our fixed comments array
                for (var i = 0; i < resultsArr.count; i++) {
                    self.comments.append(resultsArr[i]) //now append the comments
                }
                
                self.lblComments.text = "Comments (\(self.comments.count))" //print the size
               
                //if no comment and caption
                if(resultsArr.count == 0 && self.comments.count == 0){
                        self.comments.append(Comment(fullName: "",message: "no comment yet"))
                        self.lblComments.text = "Comments (0)" //size is zero if no comments
                }
                
                self.mTableView!.reloadData()
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
