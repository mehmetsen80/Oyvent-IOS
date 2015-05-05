//
//  CustomTabBarController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 4/12/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
    
        
        
        if (tabBarController.selectedIndex == 0) {
            //let homeView:HomeViewController =  nvg.topViewController as HomeViewController
            
        }
        else if (tabBarController.selectedIndex == 1) {
            var nvg: UINavigationController = tabBarController.viewControllers![1] as UINavigationController
            let geoView:GeoViewController =  nvg.topViewController as GeoViewController
            geoView.scrollToTop()  //it breaks when tab changes
        }else if(tabBarController.selectedIndex == 2){
            var meView: MeViewController = tabBarController.viewControllers![4] as MeViewController
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
