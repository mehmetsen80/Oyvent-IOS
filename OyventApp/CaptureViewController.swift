//
//  CaptureViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/21/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class CaptureViewController: UIViewController, ENSideMenuDelegate {

    var albumID : Double = 0
    var albumName : String = ""
    
    override func viewDidAppear(animated: Bool) {
        println("albumID: \(albumID)  albumName: \(albumName)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func doCancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func doShareNow(sender: UIButton) {
        println("let's share post")
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
