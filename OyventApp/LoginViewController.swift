//
//  LoginViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 3/12/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doLogin(sender: AnyObject) {
        
        let email = txtEmail.text
        let password = txtPassword.text
        
        if(email.isEmpty || password.isEmpty) { return }

        //generate url, call json and display the result
        let myUrl = NSURL(string:"http://oyvent.com/ajax/Login.php")
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "POST";
        
        let postString = "email=\(email)&password=\(password)&processType=LOGINUSER"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        self.myActivityIndicator.startAnimating()
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error  in
            
            if(error != nil){
                self.myActivityIndicator.stopAnimating()
                println("error=\(error)")
                return
            }
            
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers  , error: &err) as? NSDictionary
            
            if let parseJSON = json {
                var resultValue = parseJSON["success"] as Bool!
                println("resultValue=\(resultValue)")
                
                var message:String? = parseJSON	["message"] as String?
                var userID:Double? = parseJSON["userID"] as Double?
                var fullname:String? = parseJSON["fullname"] as String?
                var username:String? = parseJSON["username"] as String?
                var lastlogindate:String? = parseJSON["lastlogindate"] as String?
                var signupdate:String? = parseJSON["signupdate"] as String?
                
                
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    self.myActivityIndicator.stopAnimating()
                    
                    if(!resultValue){
                        //display alert message with confirmation
                        var myAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                        
                    }else{
                        
                        //store data
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
                        NSUserDefaults.standardUserDefaults().setObject(userID, forKey:"userID")
                        NSUserDefaults.standardUserDefaults().setObject(fullname, forKey:"fullname")
                        NSUserDefaults.standardUserDefaults().setObject(username, forKey:"username")
                        NSUserDefaults.standardUserDefaults().setObject(email, forKey:"email")
                        NSUserDefaults.standardUserDefaults().setObject(password, forKey:"password")
                        NSUserDefaults.standardUserDefaults().setObject(lastlogindate, forKey:"lastlogindate")
                        NSUserDefaults.standardUserDefaults().setObject(signupdate, forKey:"signupdate")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        
                        
                        let homeController:HomeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("homeView") as HomeViewController
                        //let nvg: MyNavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("myNav") as MyNavigationController
                        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                        appDelegate.window?.rootViewController = homeController
                        appDelegate.window?.makeKeyAndVisible()
                        
                    }
                })
                
            }
        }
        
        task.resume()
        
        
    }

}

