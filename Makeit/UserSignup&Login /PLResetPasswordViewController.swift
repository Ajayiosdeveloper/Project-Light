//
//  PLResetPasswordViewController.swift
//  Makeit
//
//  Created by Tharani P on 10/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLResetPasswordViewController: UIViewController,UIAlertViewDelegate {

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
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "Reset Password link will be sent to the registered email", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action : UIAlertAction) in
                let email = self.emailIdField.text
                let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                self.userAccountViewModel.sendForgotPasswordLinkToeMail(finalEmail, completion: { (err) in
                    
                       PLSharedManager.showAlertIn(self, error: err!, title: "Email is not matching with registered mail", message: "")
                    
                })
              //  self.userAccountViewModel.sendForgotPasswordLinkToeMail(finalEmail)
                let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PLUserSignupAndLoginViewController")
                self.presentViewController(loginViewController, animated: true, completion: nil)
                })
            
            self.presentViewController(alert, animated: true, completion: nil)

        } else {
            // Fallback on earlier versions
            let email = self.emailIdField.text
            let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.userAccountViewModel.sendForgotPasswordLinkToeMail(finalEmail, completion: { (err) in
                
                PLSharedManager.showAlertIn(self, error: err!, title: "Email is not matching with registered mail", message: "")
            })

//            let alertView = UIAlertView(title: "Reset Password link will be sent to the registered email", message: "", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Ok")
//            alertView.tag = 1
//            alertView.show()
        }
            
     }
      else
      {
        self.showAlertWithMessage("Invalid Email", message: "Please enter valid email")
      }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        print(buttonIndex)
        switch (alertView.tag)
        {
        case 1:
            switch (buttonIndex) {
            case 0:
                print("Ok")
                let email = self.emailIdField.text
                let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                
                self.userAccountViewModel.sendForgotPasswordLinkToeMail(finalEmail, completion: { (err) in
                    if err != nil
                    {
                        PLSharedManager.showAlertIn(self, error: err!, title: "Email is not matching with registered mail", message: "")
                    }
                })
               // self.userAccountViewModel.sendForgotPasswordLinkToeMail(finalEmail)
                let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PLUserSignupAndLoginViewController")
                self.presentViewController(loginViewController, animated: true, completion: nil)
            
            default:
                print("")
            }
            
        default:
            print("")
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
            let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Ok")
            alertView.show()
            
        }
    }
    
  }
