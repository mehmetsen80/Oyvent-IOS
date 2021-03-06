//
//  MyNavigationController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 4/19/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import Foundation
import UIKit

class MyNavigationController: ENSideMenuNavigationController, ENSideMenuDelegate {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: MyMenuTableViewController(), menuPosition:.Left)
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: MenuTableViewController(), menuPosition:.Left)

        
        //sideMenu?.delegate = self //optional
        sideMenu?.menuWidth = 180.0 // optional, default is 160
        //sideMenu?.bouncingEnabled = false
        
              
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen", terminator: "")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose", terminator: "")
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
