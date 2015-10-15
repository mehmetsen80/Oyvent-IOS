//
//  CustomTabBarController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 9/19/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        print("tabBarController selectedIndex: \(tabBarController.selectedIndex)", terminator: "")
        
        if (tabBarController.selectedIndex == 0) {
            let nvg: UINavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("navNearMe")  as! UINavigationController
            let geoView:GeoViewController =  nvg.topViewController as! GeoViewController
            geoView.scrollToTop()  //it breaks when tab changes
        }else if(tabBarController.selectedIndex == 1){
            let nvg: UINavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("navPeople") as! UINavigationController
            let peopleView: PeopleViewController = nvg.topViewController as! PeopleViewController
        }else if(tabBarController.selectedIndex == 2){
            let nvg: UINavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("navCategories") as! UINavigationController
            let groupsView: GroupsViewController = nvg.topViewController as! GroupsViewController
        }else if(tabBarController.selectedIndex == 3){
            let nvg: UINavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("navMyGallery") as! UINavigationController
            let myGalleryView: ProfilePhotosViewController = nvg.topViewController as! ProfilePhotosViewController
        }else if(tabBarController.selectedIndex == 4){
            let nvg: UINavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("navLogout") as! UINavigationController
            let myGalleryView: LogoutViewController = nvg.topViewController as! LogoutViewController
        }else if(tabBarController.selectedIndex == 5){
            let nvg: UINavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("navProfile") as! UINavigationController
        }
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
