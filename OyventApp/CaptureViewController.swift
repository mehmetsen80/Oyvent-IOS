//
//  CaptureViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/21/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation




class CaptureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {

    var geoCoder: CLGeocoder!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var latitude : String!
    var longitude : String!
    
    var albumID : Double = 0
    var albumName : String = ""
    var city:String = ""
    let bgImageColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
    var segueLibrary: Bool = false
    
    @IBOutlet weak var btnShareNow: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnClose2: UIButton!
  
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var captureSession: AVCaptureSession! = nil
    var previewLayer : AVCaptureVideoPreviewLayer?
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: UIImagePickerController!
 
    @IBOutlet weak var btnAlbumName: UIButton!
    @IBOutlet weak var txtAddCaption: UITextField!
    @IBOutlet weak var btnLibrary: UIButton!
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    var stillImageOutput: AVCaptureStillImageOutput?
    
    enum CameraType {
        case Front
        case Back
    }
    
    var currentCamera = CameraType.Back
    
    override func viewDidAppear(animated: Bool) {
        //println("albumID: \(albumID)  albumName: \(albumName)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        btnAlbumName.setTitle(albumName, forState: UIControlState.Normal)
    
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        initSession()
        setupDevices()
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
                    if(self.segueLibrary){//trigger the library button image if segue from library
                        self.btnLibrary.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                    }
                    self.locationManager.stopUpdatingLocation()
                }
            }
        })
    }

    
    
    //setup the devices flip flow back and front camera
    func setupDevices(){
        
        let devices = AVCaptureDevice.devices()
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                
                if (currentCamera == CameraType.Front) {
                    // Finally check the position and confirm we've got the front camera
                    if device.position == AVCaptureDevicePosition.Front {
                        captureDevice = device as? AVCaptureDevice
                        if captureDevice != nil {
                            println("Capture Front device found")
                            currentCamera = CameraType.Front
                            beginSession()
                            break
                        }
                    }
                }else{
                    // Finally check the position and confirm we've got the back camera
                    if device.position == AVCaptureDevicePosition.Back {
                        captureDevice = device as? AVCaptureDevice
                        if captureDevice != nil {
                            println("Capture Back device found")
                            currentCamera = CameraType.Back
                            beginSession()
                            break
                        }
                    }
                }
            }
        }
        
        
        
    }
    
    // not used right now
    func hasFrontCamera() -> Bool {
        let devices = AVCaptureDevice.devices()
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Front){
                    return true
                }
            }
        }
        
        return false
    }
    
    
    // not used right now
    func hasFlash() -> Bool {
        
        let devices = AVCaptureDevice.devices()
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back){
                    return device.hasFlash
                }
            }
        }
        
        return false
    }

   
    
    func configureDevice() {
        
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            //device.focusMode = .Locked
            device.unlockForConfiguration()
        }
    }
    
    func resetSession() {
        
        var err: NSError? = nil
        let inputs = captureSession.inputs as! [AVCaptureInput]
        var input = AVCaptureDeviceInput(device: captureDevice, error: &err)
        if( contains(inputs, input) ) {
            captureSession.removeInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        }
        
        if captureSession.running {
            captureSession.stopRunning()
            if(!self.imageView.layer.sublayers.isEmpty){
                self.previewLayer?.removeFromSuperlayer()
            }
        }
        
        previewLayer = nil
        captureSession = nil
        imageView.image = UIImage(named: "blank")
        
    }
    
    func initSession(){
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession.addOutput(stillImageOutput)
        
    }
    
    func beginSession() {
        
        configureDevice()
        
        var err: NSError? = nil
        var input = AVCaptureDeviceInput(device: captureDevice, error: &err)
        let inputs = captureSession.inputs as! [AVCaptureInput]
        
        
        if( !contains(inputs, input) ){
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        }
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        //create preview layer and add it the imageview and start session
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.imageView.layer.addSublayer(previewLayer)
        if !captureSession.running {
            captureSession.startRunning()
        }
        
        
        //adjust the preview layer bounds to put the video inside the imageview
        var bounds: CGRect? = self.imageView.layer.bounds as CGRect
        self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer?.bounds = bounds!
        self.previewLayer?.position = CGPointMake(CGRectGetMidX(bounds!), CGRectGetMidY(bounds!))
        
        
    }

    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func doCancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func shareNow(sender: UIButton) {
        
        var userID: Double = NSUserDefaults.standardUserDefaults().doubleForKey("userID")
        let url = NSURL(string:"http://oyvent.com/ajax/PhotoHandlerWeb.php")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let caption = txtAddCaption.text
    
        let param = [
            "processType" : "UPLOADIOSPHOTO",
            "albumID" : "\(self.albumID)",
            "userID" : "\(userID)",
            "latitude" : "\(self.latitude)",
            "longitude" : "\(self.longitude)",
            "caption" : "\(caption)"
        ]
        
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let img : UIImage = self.fixOrientation(self.imageView.image!)
        var imageData = UIImageJPEGRepresentation(img, 1)
        if(imageData==nil) { return; }
        
        btnShareNow.enabled = false
        activityIndicator.startAnimating()
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error  in
            
            if(error != nil){
                println("error=\(error)")
                return
            }
            
//            // You can print out response object
//            println("******* response = \(response)")
            
            
            // Print out reponse body
//            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println("****** response data = \(responseString!)")
            
            
            
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
                        self.activityIndicator.stopAnimating()
                        self.btnShareNow.enabled = true
                    }else{
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                        self.txtAddCaption.text = ""
//                        self.imageView.image = nil;
                        
                        //display alert message with confirmation
                        var myAlert = UIAlertController(title: "Confirmation", message: "Post added successfully!", preferredStyle: UIAlertControllerStyle.Alert)
                        myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                            
                            //self.dismissViewControllerAnimated(true, completion: nil)
                            self.activityIndicator.stopAnimating()
                            self.btnClose2.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            
//                            let nvg: MyNavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("myGeoNav") as MyNavigationController
//                            var geoController:GeoViewController =  nvg.topViewController as GeoViewController
//                        
//                            geoController.hasCustomNavigation = true
//                            geoController.albumID = self.albumID
//                            geoController.albumName = self.albumName
//                            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//                            appDelegate.window?.rootViewController = nvg
//                            appDelegate.window?.makeKeyAndVisible()
                            
                            
                        }))
                        self.presentViewController(myAlert, animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                        self.btnShareNow.enabled = true
                    }
                })
            }
        }
        
        task.resume()
        
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        
        var body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "oyvent-photo.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    

    
    
    /// Create boundary string for multipart/form-data request
    ///
    /// :returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
   
    
  
    //shoot a photo
    @IBAction func takePhoto(sender: UIButton) {
        
        
        if(!self.captureSession.running){
            self.imageView.layer.addSublayer(previewLayer)
            self.captureSession.startRunning()
            return
        }
        
        var videoConnection :AVCaptureConnection?
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer, error) in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                
                var initialImage : UIImage = UIImage(data: imageData)!
                let orientedImage = UIImage(CGImage: initialImage.CGImage, scale: 1, orientation: initialImage.imageOrientation)!
               
                self.imageView.image = orientedImage
                self.captureSession.stopRunning()
                
                //Save the captured preview to image
                UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil)
                
            })
        }
    }
    
    //get photo from gallery
    @IBAction func fromLibrary(sender: UIButton) {
        
        if(!self.captureSession.running){
            self.imageView.layer.addSublayer(previewLayer)
            self.captureSession.startRunning()
        }
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.modalPresentationStyle = .Popover
        presentViewController(imagePicker, animated: true, completion: nil)//4
        //imagePicker.popoverPresentationController?.barButtonItem = sender
    }
    
    func fixOrientation(img:UIImage) -> UIImage {
        
        
        // No-op if the orientation is already correct
        if (img.imageOrientation == UIImageOrientation.Up) {
            return img;
        }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransformIdentity
        
        if (img.imageOrientation == UIImageOrientation.Down
            || img.imageOrientation == UIImageOrientation.DownMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, img.size.height)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
        
        if (img.imageOrientation == UIImageOrientation.Left
            || img.imageOrientation == UIImageOrientation.LeftMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, 0)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        
        if (img.imageOrientation == UIImageOrientation.Right
            || img.imageOrientation == UIImageOrientation.RightMirrored) {
                
                transform = CGAffineTransformTranslate(transform, 0, img.size.height);
                transform = CGAffineTransformRotate(transform,  CGFloat(-M_PI_2));
        }
        
        if (img.imageOrientation == UIImageOrientation.UpMirrored
            || img.imageOrientation == UIImageOrientation.DownMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, 0)
                transform = CGAffineTransformScale(transform, -1, 1)
        }
        
        if (img.imageOrientation == UIImageOrientation.LeftMirrored
            || img.imageOrientation == UIImageOrientation.RightMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
        }
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        var ctx:CGContextRef = CGBitmapContextCreate(nil, Int(img.size.width), Int(img.size.height),
            CGImageGetBitsPerComponent(img.CGImage), 0,
            CGImageGetColorSpace(img.CGImage),
            CGImageGetBitmapInfo(img.CGImage));
        CGContextConcatCTM(ctx, transform)
        
        
        if (img.imageOrientation == UIImageOrientation.Left
            || img.imageOrientation == UIImageOrientation.LeftMirrored
            || img.imageOrientation == UIImageOrientation.Right
            || img.imageOrientation == UIImageOrientation.RightMirrored
            ) {
                
                CGContextDrawImage(ctx, CGRectMake(0,0,img.size.height,img.size.width), img.CGImage)
        } else {
            CGContextDrawImage(ctx, CGRectMake(0,0,img.size.width,img.size.height), img.CGImage)
        }
        
        
        // And now we just create a new UIImage from the drawing context
        var cgimg:CGImageRef = CGBitmapContextCreateImage(ctx)
        var imgEnd:UIImage = UIImage(CGImage: cgimg)!
        
        return imgEnd
    }
    
    
   //change camera type to front or back and restore session
    @IBAction func switchCamera(sender: UIButton) {
        resetSession()
        initSession()
        currentCamera =  (currentCamera == CameraType.Front) ? CameraType.Back : CameraType.Front
        setupDevices()
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if(captureSession.running){
            captureSession.stopRunning()
        }
        
        if(imageView.layer.sublayers != nil){
           // if(!imageView.layer.sublayers.isEmpty)
            previewLayer?.removeFromSuperlayer()
        }
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.contentMode = .ScaleAspectFit
        imageView.image = chosenImage
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func focusTo(value : Float) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
                        //
                })
                device.unlockForConfiguration()
            }
        }
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var anyTouch = touches.first as! UITouch
        var touchPercent = anyTouch.locationInView(self.view).x / screenWidth
        focusTo(Float(touchPercent))
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var anyTouch = touches.first as! UITouch
        var touchPercent = anyTouch.locationInView(self.view).x / screenWidth
        focusTo(Float(touchPercent))
        
        self.view.endEditing(true);
    }
    
    //keep this here for enabling Did End Editing of add comment textbos
    @IBAction func txtDidonExit(sender: AnyObject) {}
    
    /**************** move add comment textbox up **************/
    @IBAction func txtDidBeginEditing(sender: AnyObject) {
        animateViewMoving(true, moveValue: 225)
    }/************ end of move add comment textbox up **********/
    
    /********* move add comment textbox back down ***********/
    @IBAction func txtDidEndEditing(sender: AnyObject) {
         animateViewMoving(false, moveValue: 225)
    }/****** end of move add comment textbox back down ******/
    
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
    

}


extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
