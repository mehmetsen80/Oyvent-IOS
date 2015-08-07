//
//  MenuTableViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 7/26/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation
import UIKit

class MenuTableViewController: UITableViewController {

    var selectedMenuItem : Int = -1
    
    //section 0
    var menuHomeCell: UITableViewCell = UITableViewCell()
    var menuLabelHome: UILabel = UILabel()
    var menuNearMeCell: UITableViewCell = UITableViewCell()
    var menuLabelNearMe: UILabel = UILabel()
    
    //section 1
    var menuMyGroupsCell: UITableViewCell = UITableViewCell()
    var menuLabelGroups: UILabel = UILabel()
    var menuMyProfileCell: UITableViewCell = UITableViewCell()
    var menuLabelMyProfile: UILabel = UILabel()
    var menuLogoutCell: UITableViewCell = UITableViewCell()
    var menuLabelLogout: UILabel = UILabel()
    
    //empty 1
    var menuEmptyCell1: UITableViewCell = UITableViewCell()
    var menuLabelEmpty1: UILabel = UILabel()
    
    //empty 2
    var menuEmptyCell2: UITableViewCell = UITableViewCell()
    var menuLabelEmpty2: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        
        
        // construct first name cell, section 0, row 0
        self.menuLabelHome = UILabel(frame: CGRectInset(self.menuHomeCell.contentView.bounds, 15, 0))
        self.menuLabelHome.font = UIFont(name: "HelveticaNeue", size: CGFloat(20))
        self.menuLabelHome.text = "Home"
        self.menuHomeCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.menuHomeCell.addSubview(self.menuLabelHome)
        
        // construct first name cell, section 0, row 1
        
        self.menuLabelNearMe = UILabel(frame: CGRectInset(self.menuNearMeCell.contentView.bounds, 15, 0))
        self.menuLabelNearMe.font = UIFont(name: "HelveticaNeue", size: CGFloat(20))
        self.menuLabelNearMe.text = "Near Me"
        self.menuNearMeCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.menuNearMeCell.addSubview(self.menuLabelNearMe)
        
        
       
        
//        //To do: create groups to browse
//        // construct share cell, section 1, row 0
//        self.menuLabelGroups = UILabel(frame: CGRectInset(self.menuMyGroupsCell.contentView.bounds, 15, 0))
//        self.menuLabelGroups.font = UIFont(name: "HelveticaNeue", size: CGFloat(14))
//        self.menuLabelGroups.text = "Groups"
//        self.menuMyGroupsCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
//        self.menuMyGroupsCell.addSubview(self.menuLabelGroups)
        
        // construct last name cell, section 1, row 1
        self.menuLabelMyProfile = UILabel(frame: CGRectInset(self.menuMyProfileCell.contentView.bounds, 15, 0))
        self.menuLabelMyProfile.font = UIFont(name: "HelveticaNeue", size: CGFloat(20))
        self.menuLabelMyProfile.text = "My Profile"
        self.menuMyProfileCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.menuMyProfileCell.addSubview(self.menuLabelMyProfile)
        
        // construct last name cell, section 1, row 2
        self.menuLabelLogout = UILabel(frame: CGRectInset(self.menuLogoutCell.contentView.bounds, 15, 0))
        self.menuLabelLogout.font = UIFont(name: "HelveticaNeue", size: CGFloat(20))
        self.menuLabelLogout.text = "Logout"
        self.menuLogoutCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.menuLogoutCell.addSubview(self.menuLabelLogout)
        
        //empty cell 1
        self.menuLabelEmpty1 = UILabel(frame: CGRectInset(self.menuEmptyCell1.contentView.bounds, 15, 0))
        self.menuLabelEmpty1.font = UIFont(name: "HelveticaNeue", size: CGFloat(20))
        self.menuLabelEmpty1.text = ""
        self.menuEmptyCell1.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.menuEmptyCell1.addSubview(menuLabelEmpty1)
        
        //empty cell 2
        self.menuLabelEmpty2 = UILabel(frame: CGRectInset(self.menuEmptyCell2.contentView.bounds, 15, 0))
        self.menuLabelEmpty2.font = UIFont(name: "HelveticaNeue", size: CGFloat(20))
        self.menuLabelEmpty2.text = ""
        self.menuEmptyCell2.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.menuEmptyCell2.addSubview(menuLabelEmpty2)
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)

    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // Background color
        //view.tintColor = UIColor.grayColor()
        view.tintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)

        // Text Color/Font
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.textColor = UIColor.whiteColor()
        header.textLabel.font = UIFont(name: "HelveticaNeue", size: CGFloat(20))
    }
    
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //return if
        if (indexPath.row == selectedMenuItem) {
            return
        }
        
        selectedMenuItem = indexPath.row
        
        //Present new view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //if not logged in
        var isUserLoggedIn:Bool = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        if(!isUserLoggedIn){
            var loginViewController = mainStoryboard.instantiateViewControllerWithIdentifier("loginView")as! LoginViewController
            appDelegate.window?.rootViewController = loginViewController
            appDelegate.window?.makeKeyAndVisible()
        }else{
        
        println("index path: \(indexPath.row)")
            
            if(indexPath.section == 0){
                
                switch (indexPath.row) {
            
                case 0:
                let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("myMainNav") as! MyNavigationController
                var mainViewController:MainViewController =  nvg.topViewController as! MainViewController
                appDelegate.window?.rootViewController = nvg
                appDelegate.window?.makeKeyAndVisible()
                
                break
                case 1:
                    //tabBarController.selectedIndex = 1
                    let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("myNavGeo") as! MyNavigationController
                    var geoViewController:GeoViewController =  nvg.topViewController as! GeoViewController
                    geoViewController.hasCustomNavigation = true
                    appDelegate.window?.rootViewController = nvg
                    appDelegate.window?.makeKeyAndVisible()
                break
                default:
                break
                }
            }else if(indexPath.section == 1){
                switch (indexPath.row) {
                    
                case 0:
                    //My Profile
                    let nvg: MyNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("myNavProfile") as! MyNavigationController
                    var profileViewController:ProfileViewController =  nvg.topViewController as! ProfileViewController
                    //to do: set things about profile if you need before navigating to profile view
                    appDelegate.window?.rootViewController = nvg
                    appDelegate.window?.makeKeyAndVisible()
                    break
                case 1:
                    //logout
                    var logoutView: LogoutViewController = mainStoryboard.instantiateViewControllerWithIdentifier("logoutView") as! LogoutViewController
                    sideMenuController()?.setContentViewController(logoutView)
                    break
                    
                default:
                    break
                }
            }
            
            
    
            
        }
    }

    
    // Customize the section headings for each section
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0: return "Social"
        case 1: return "Profile"
        default: fatalError("Unknown section")
        }
    }
    
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        switch(section) {
        case 0: return 2    // section 0 has 2 rows
        case 1: return 2    // section 1 has 2 rows
        default: fatalError("Unknown number of sections")
        }
    }
  

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0: return self.menuHomeCell   // section 0, row 0
            case 1: return self.menuNearMeCell  // section 0, row 1
            //case 2: return self.menuEmptyCell1 // section 0, row 2
            default: fatalError("Unknown row in section 0")
            }
        case 1:
            switch(indexPath.row) {
            case 0: return self.menuMyProfileCell       // section 1, row 0
            case 1: return self.menuLogoutCell      // section 1, row 1
            //case 2: return self.menuEmptyCell2 // section 1, row 2

            default: fatalError("Unknown row in section 1")
            }
        default: fatalError("Unknown section")
        }

        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
