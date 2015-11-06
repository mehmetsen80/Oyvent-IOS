//
//  SelectPhotoViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 11/3/15.
//  Copyright © 2015 Oyvent. All rights reserved.
//

import UIKit

class SelectPhotoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindFromCaptureProfilePhoto(segue: UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if segue.identifier == "showFromCamera"{
            let captureProfilePhoto: CaptureProfilePhotoViewController = segue.destinationViewController as! CaptureProfilePhotoViewController
            captureProfilePhoto.launchType = PhotoSource.Camera.description
            
        }else if segue.identifier == "showFromGallery"{
            let captureProfilePhoto: CaptureProfilePhotoViewController = segue.destinationViewController as! CaptureProfilePhotoViewController
            captureProfilePhoto.launchType = PhotoSource.Gallery.description
            
        }
    
    }
    

}