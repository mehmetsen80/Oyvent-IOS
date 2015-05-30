//
//  CategoryViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/24/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController,UIPopoverPresentationControllerDelegate {

    var albumID : Double = 0
    var albumName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelCategory(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "takePhoto" {
            var captureViewController: CaptureViewController = segue.destinationViewController as CaptureViewController
            captureViewController.albumID = self.albumID
            captureViewController.albumName = self.albumName
            //captureViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            //captureViewController.popoverPresentationController!.delegate = self
        }else if segue.identifier == "fromLibrary" {
            var captureViewController: CaptureViewController = segue.destinationViewController as CaptureViewController
            captureViewController.albumID = self.albumID
            captureViewController.albumName = self.albumName
            captureViewController.segueLibrary = true
//            captureViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
//            captureViewController.popoverPresentationController!.delegate = self
        }else if segue.identifier == "onlyText" {
            var onlyTextViewController: OnlyTextViewController = segue.destinationViewController as OnlyTextViewController
            onlyTextViewController.albumID = self.albumID
            onlyTextViewController.albumName = self.albumName
//            onlyTextViewController.popoverPresentationController!.delegate = self
//            onlyTextViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        }


    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        println("welcome back!")
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    

}
