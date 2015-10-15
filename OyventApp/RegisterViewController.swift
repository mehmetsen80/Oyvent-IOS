//
//  RegisterViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 3/15/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func doSignup(sender: AnyObject) {
        
        let fullname = txtFullName.text
        let email = txtEmail.text
        let password = txtPassword.text
        
        //check for empty fields
        if(fullname!.isEmpty || email!.isEmpty || password!.isEmpty){
            //display alert message
            displayAlertMessage("All fields are required!")
            return
        }
        
        //generate url, call json and display the result
        let myUrl = NSURL(string:"http://oyvent.com/ajax/Register.php")
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "POST";
        let postString = "email=\(email)&password=\(password)&fullname=\(fullname)&processType=SIGNUPUSER"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        self.myActivityIndicator.startAnimating()
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if(error != nil){
                print("error=\(error)", terminator: "")
                return
            }
            
            //var err: NSError?
            do{
                let parseJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers  ) as? NSDictionary
            
            
                let resultValue = parseJSON?["success"] as! Bool
                print("resultValue=\(resultValue)")
                
                let message:String = parseJSON?["message"] as! String!
                let userID:Double = parseJSON?["userID"] as! Double!
                let username:String? = parseJSON?["username"] as? String
                let lastlogindate:String = parseJSON?["lastlogindate"] as! String!
                let signupdate:String = parseJSON?["signupdate"] as! String!
                let isadmin:Bool = parseJSON?["isadmin"] as! Bool!
                
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    self.myActivityIndicator.stopAnimating()
                    
                    if(!resultValue){
                        //display alert message with confirmation
                        let myAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        
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
                        NSUserDefaults.standardUserDefaults().setBool(isadmin, forKey: "isadmin")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        
                        //display alert message with confirmation
                        let myAlert = UIAlertController(title: "Alert", message: "Welcome to Oyvent!", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let okAction = UIAlertAction(title: "Let's Start!", style: UIAlertActionStyle.Default){ action in
                            self.dismissViewControllerAnimated(true, completion:nil)
                        }
                        
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                        
                        //let homeController:HomeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("homeView") as HomeViewController
                        let nvg: MyNavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("myMainNav") as! MyNavigationController
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.window?.rootViewController = nvg
                        appDelegate.window?.makeKeyAndVisible()
                    }
                })
                
            }catch{}
        }
        
        task.resume()
        
        
    }
    
    func displayAlertMessage(alertMessage:String){
        let myAlert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated:true, completion:nil)
        
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
