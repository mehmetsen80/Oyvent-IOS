//
//  LogoutViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 7/3/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class LogoutViewController: UIViewController, ENSideMenuDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sideMenuController()?.sideMenu?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        var menuImage:UIImage = UIImage(named: "oyvent-icon-72")!
        menuImage = resizeImage(menuImage,targetSize: CGSize(width: 30, height: 30))
        menuImage = menuImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        var leftButton = UIBarButtonItem(image: menuImage, style: UIBarButtonItemStyle.Bordered, target: self, action: "sideMenuClicked")
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        
        if(!isUserLoggedIn){
            self.performSegueWithIdentifier("loginView", sender: self)
        }
        
        setupNavigationBar()
    }
    
    func sideMenuClicked(){
        toggleSideMenuView()
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        println("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        println("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        println("sideMenuShouldOpenSideMenu")
        return true
    }
    
    @IBAction func doLogout(sender: UIButton) {
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"userID")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"fullname")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"username")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"email")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"password")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"lastlogindate")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"signupdate")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isadmin")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let loginViewController:LoginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("loginView") as LoginViewController
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.window?.rootViewController = loginViewController
        appDelegate.window?.makeKeyAndVisible()
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "loginView"){
            println("it works!")
        }
    }
    

}
