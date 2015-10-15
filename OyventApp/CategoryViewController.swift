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
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnClose2: UIButton!
    
    
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

    @IBAction func closeCategory(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "takePhoto" {
            let captureViewController: CaptureViewController = segue.destinationViewController as! CaptureViewController
            captureViewController.albumID = self.albumID
            captureViewController.albumName = self.albumName
            //captureViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            //captureViewController.popoverPresentationController!.delegate = self
        }else if segue.identifier == "fromLibrary" {
            let captureViewController: CaptureViewController = segue.destinationViewController as! CaptureViewController
            captureViewController.albumID = self.albumID
            captureViewController.albumName = self.albumName
            captureViewController.segueLibrary = true
//            captureViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
//            captureViewController.popoverPresentationController!.delegate = self
        }else if segue.identifier == "onlyText" {
            let onlyTextViewController: OnlyTextViewController = segue.destinationViewController as! OnlyTextViewController
            onlyTextViewController.albumID = self.albumID
            onlyTextViewController.albumName = self.albumName
//            onlyTextViewController.popoverPresentationController!.delegate = self
//            onlyTextViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        }


    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        print("welcome back to CategoryViewController!", terminator: "")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func unwindToThisViewController2(ssegue: UIStoryboardSegue) {
        print("unwind2", terminator: "")
        self.btnClose2.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    

}
