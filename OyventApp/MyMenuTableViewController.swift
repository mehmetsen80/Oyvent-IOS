//
//  MyMenuTableViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

class MyMenuTableViewController: UITableViewController {
    var selectedMenuItem : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
        
       

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkGrayColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        switch(indexPath.row){
            case 0:
                cell!.textLabel?.text = "Home"
                break
            case 1:
                cell!.textLabel?.text = "Near Me"
                break
            case 2:
                cell!.textLabel?.text = "Logout" //me uiviewcontrol
                break
            default:
                cell!.textLabel?.text = "Home"
                break
        }
        
        
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println("did select row: \(indexPath.row)")
        
        if (indexPath.row == selectedMenuItem) {
            return
        }
        selectedMenuItem = indexPath.row
        
        //Present new view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        var isUserLoggedIn:Bool = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        
        if(!isUserLoggedIn){
            var loginViewController = mainStoryboard.instantiateViewControllerWithIdentifier("loginView") as LoginViewController
            
            appDelegate.window?.rootViewController = loginViewController
            appDelegate.window?.makeKeyAndVisible()
        }else{
            
            //            var homeController:MainViewController = mainStoryboard.instantiateViewControllerWithIdentifier("homeView") as MainViewController
            
            //let tabController:CustomTabBarController = mainStoryboard.instantiateViewControllerWithIdentifier("customTabBar") as CustomTabBarController
            
//            window!.rootViewController = homeController
//            appDelegate.window?.rootViewController = tabController
//            appDelegate.window?.makeKeyAndVisible()
//            if let tabBarController = appDelegate.window?.rootViewController as? CustomTabBarController {
            
                switch (indexPath.row) {
                case 0:
                   //tabBarController.selectedIndex = 0
//                   var homeView: HomeViewController = tabBarController.viewControllers![0] as HomeViewController
                     let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("myNav") as MyNavigationController
                   let homeController: HomeViewController = nvg.topViewController as HomeViewController
                   sideMenuController()?.setContentViewController(homeController)
                    break
                case 1:
                    //tabBarController.selectedIndex = 1
                    let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("myGeoNav") as MyNavigationController
                    let geoController:GeoViewController =  nvg.topViewController as GeoViewController
                    geoController.hasCustomNavigation = true
//                     let geoController: GeoViewController = mainStoryboard.instantiateViewControllerWithIdentifier("geoView") as GeoViewController
                    
                    sideMenuController()?.setContentViewController(geoController)
                    break
                case 2:
                    //tabBarController.selectedIndex = 4
                    var meView: MeViewController = mainStoryboard.instantiateViewControllerWithIdentifier("meView") as MeViewController
                    sideMenuController()?.setContentViewController(meView)
                    
                    break
                case 3:
                    //tabBarController.selectedIndex = 3
                    break
                case 4:
                    break
                default:
                    //tabBarController.selectedIndex = 0
                    break
                }
                
                
                
//            }
        }
        
        
        
//        var destViewController : UIViewController
//        switch (indexPath.row) {
//        case 0:
//            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("GeoViewController") as UIViewController
//            break
//        case 1:
//            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MeViewController") as UIViewController
//            break
//        case 2:
//            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController3") as UIViewController
//            break
//        default:
//            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("GeoViewController") as UIViewController
//            break
//        }
//        sideMenuController()?.setContentViewController(destViewController)
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
