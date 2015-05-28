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
                
                // City
                if let city = placeMark.addressDictionary["City"] as? NSString {
                    //println(city)
                    self.city = city
                    self.albumName = (self.albumID != 0 ) ? self.albumName : city
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
        let inputs = captureSession.inputs as [AVCaptureInput]
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
        let inputs = captureSession.inputs as [AVCaptureInput]
        
        
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
        println("let's share post")
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
               
                self.imageView.image = UIImage(data: imageData)
                self.captureSession.stopRunning()
                
                //Save the captured preview to image
                //UIImageWriteToSavedPhotosAlbum(self.mImageView.image, nil, nil, nil)
                
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
        
        if(!imageView.layer.sublayers.isEmpty){
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
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var anyTouch = touches.anyObject() as UITouch
        var touchPercent = anyTouch.locationInView(self.view).x / screenWidth
        focusTo(Float(touchPercent))
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var anyTouch = touches.anyObject() as UITouch
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
