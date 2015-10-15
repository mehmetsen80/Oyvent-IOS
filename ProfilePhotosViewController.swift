//
//  ProfilePhotosViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 8/20/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit
import CoreLocation

class ProfilePhotosViewController: GalleryViewController, GalleryDataSource, CLLocationManagerDelegate {

    var imageURLs: [String]!
    @IBOutlet weak var btnCity: UIButton!
    var geoCoder: CLGeocoder!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var latitude : String!
    var longitude : String!
    var city:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        imageURLs = ["http://img1.3lian.com/img2011/w1/103/41/d/50.jpg", "http://www.old-radio.info/wp-content/uploads/2014/09/cute-cat.jpg", "http://static.tumblr.com/aeac4c29583da7972652d382d8797876/sz5wgey/Tejmpabap/tumblr_static_cats-1.jpg", "http://resources2.news.com.au/images/2013/11/28/1226770/056906-cat.jpg"]
        
        /* hard to show 100 images in pageControl */
        /*for i in 0...99 {
        let formattedIndex = String(format: "%03d", i)
        imageURLs.append("https://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage\(formattedIndex).jpg")
        }*/
        
        //let's make it only 10 images to show in pageControl
        for i in 0...20 {
            let formattedIndex = String(format: "%03d", i)
            imageURLs.append("https://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage\(formattedIndex).jpg")
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
         setupLocationManager();
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile Photos"
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gallery(gallery: GalleryViewController, numberOfImagesInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func gallery(gallery: GalleryViewController, imageURLAtIndexPath indexPath: NSIndexPath) -> String {
        return imageURLs[indexPath.row]
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
        
        //println("didUpdateToLocation longitude \(self.latitude)")
        //println("didUpdateToLocation latitude \(self.longitude)")
        
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            placemarks, error in
            
            if error == nil && placemarks!.count > 0 {
                let placeArray = placemarks as [CLPlacemark]?
                // Place details
                let placeMark: CLPlacemark! = placeArray?[0]
                
                // Address dictionary
                //println(placeMark.addressDictionary)
                
                // City
                if let city = placeMark.addressDictionary?["City"] as? NSString {
                    //println(city)
                    
                    self.city = city as String
                    self.btnCity.setTitle(city as String, forState: UIControlState.Normal)
                    //                    self.btnGeoAlbum.setTitle(self.albumName, forState: UIControlState.Normal)
                    self.locationManager.stopUpdatingLocation()
                }

                
            }
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
