//
//  PLResetPasswordViewController.swift
//  Makeit
//
//  Created by Tharani P on 10/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLResetPasswordViewController: UIViewController,UIAlertViewDelegate,UITextFieldDelegate {

    @IBOutlet weak var emailIdField: UITextField!
    @IBOutlet var resetPasswordButton: UIButton!
    
    lazy private var userAccountViewModel:PLUserSignupAndLoginViewModel = {
        return PLUserSignupAndLoginViewModel()
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        emailIdField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetPassword(sender: UIButton)
    {
        PLDynamicEngine.animateButton(resetPasswordButton)
      if userAccountViewModel.isValidEmail(emailIdField.text!)
      {
        if #available(iOS 8.0, *) {
            
         
            self.userAccountViewModel.sendForgotPasswordLinkToeMail(emailIdField.text!, completion: { (err) in
                if (err != nil)
                {
                
                  PLSharedManager.showAlertIn(self, error:err!, title: "Email is not matching with registered mail", message: "")
                   
                }
                else
                {
                
                    let alert = UIAlertController(title: "Reset Password link will be sent to the registered email", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action : UIAlertAction) in
                                 
                    
                    let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PLUserSignupAndLoginViewController")
                        self.presentViewController(loginViewController, animated: true, completion: nil)
                                    
                    })
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })

        }
        else {
            // Fallback on earlier versions

            self.userAccountViewModel.sendForgotPasswordLinkToeMail(emailIdField.text!, completion: { (err) in
                
                if let _ = err
                {
                PLSharedManager.showAlertIn(self, error: err!, title: "Email is not matching with registered mail", message: "")
                }
                else
                {
                    let alertView = UIAlertView(title: "Reset Password link will be sent to the registered email", message: "", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Ok")
                    alertView.tag = 1
                    alertView.show()
                }
            })
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
