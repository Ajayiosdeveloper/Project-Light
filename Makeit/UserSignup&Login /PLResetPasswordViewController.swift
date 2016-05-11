//
//  PLResetPasswordViewController.swift
//  Makeit
//
//  Created by Tharani P on 10/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailIdField: UITextField!
    
    lazy private var userAccountViewModel:PLUserSignupAndLoginViewModel = {
        return PLUserSignupAndLoginViewModel()
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func resetPassword(sender: AnyObject) {
      if userAccountViewModel.isValidEmail(emailIdField.text!)
      {
         let email = self.emailIdField.text
         let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
         userAccountViewModel.sendForgotPasswordLinkToeMail(finalEmail)
        // self.navigationController?.popViewControllerAnimated(true)
        let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PLUserSignupAndLoginViewController")
        self.presentViewController(loginViewController, animated: true, completion: nil)
      }
      else{
        self.showAlertWithMessage("Invalid Email", message: "Please enter valid emailId")
        }
      
    }
    func showAlertWithMessage(title:String,message:String)
    {
        
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            
            alertController.addAction(action)
            self.presentViewController(alertController, animated:true, completion:nil)
        } else {
            // Fallback on earlier versions
        }
     
        
        
    }
    
  }
