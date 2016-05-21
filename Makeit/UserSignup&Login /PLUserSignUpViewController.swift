//
//  PLUserSignUpViewController.swift
//  Makeit
//
//  Created by Tharani P on 10/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLUserSignUpViewController: UIViewController,UITextFieldDelegate
{
    @IBOutlet var signupUserNameTextField: UITextField!
    @IBOutlet var signupUserPasswordTextField: UITextField!
    @IBOutlet var signupUserConfirmPasswordTextField: UITextField!
    @IBOutlet var userSignup: UIButton!
    @IBOutlet weak var emailIdField: UITextField!
    var sideBarRootViewController:PLSidebarRootViewController!
    
    var projectsViewController:PLProjectsViewController!
    
    lazy private var userAccountViewModel:PLUserSignupAndLoginViewModel = {
        return PLUserSignupAndLoginViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userSignup.enabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: UITextfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //Signup fields first responder transfering
         if textField == emailIdField{
            if textField.text?.characters.count > 0 {signupUserNameTextField.becomeFirstResponder()}
        }
        else if textField == signupUserNameTextField{
            if textField.text?.characters.count > 0{signupUserPasswordTextField.becomeFirstResponder()}
        }
        else if textField == signupUserPasswordTextField{
            if textField.text?.characters.count > 0{signupUserConfirmPasswordTextField.becomeFirstResponder()}
        }
        else if textField == signupUserConfirmPasswordTextField{
            if textField.text?.characters.count > 0 {textField.resignFirstResponder()}
        }
       
        return true
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        //Signup button enabling & disabling
        if emailIdField.text?.characters.count > 0 && signupUserNameTextField.text?.characters.count > 0 && signupUserPasswordTextField.text?.characters.count > 0 && signupUserConfirmPasswordTextField.text?.characters.count > 0
            {
            userSignup.setTitleColor(enableButtonColor, forState: UIControlState.Normal); userSignup.enabled = true
            }
            else
            {
            userSignup.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal); userSignup.enabled = false
            }
        
        return true
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == kSignupResultNotifier{
            print("Coming in notifier")
           //handleStatus(change,tag:kSignupTag)
            
        }
    }
    
    func clearTextfields(){
        self.signupUserNameTextField.text = ""
        self.signupUserPasswordTextField.text = ""
        self.signupUserConfirmPasswordTextField.text = ""
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
            let alert = UIAlertView(title: title, message: message, delegate:nil, cancelButtonTitle:"Ok", otherButtonTitles:"") as UIAlertView
            alert.show()

            // Fallback on earlier versions
        }
            }

    /*func handleStatus(change:[String:AnyObject]?,tag:Int){
        
        if let _ = change, value = change![NSKeyValueChangeNewKey]{
            
            if value as! NSNumber == 1 { // Handling Alert Messages for Sign in
                if tag == 0{ clearTextfields()}
                 print("Coming in handle")
                presentProjectsViewController()
            }
            else{ // Handling Alert Messages for Login
                
                if tag == 0 {showAlertWithMessage("Failed!", message:"User name already exist.Please try another")}
                else{showAlertWithMessage("Error!", message:"Please try again")}
            }
        }
    }*/
    func presentProjectsViewController(){
      
        if (sideBarRootViewController == nil){
            
           sideBarRootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLSidebarRootViewController") as! PLSidebarRootViewController
        }
    
        self.presentViewController(sideBarRootViewController, animated: true, completion:nil)
        
      
    }
    
  
    
    @IBAction func signupNewUser(sender: AnyObject) {
        
        if userAccountViewModel.isValidEmail(self.emailIdField.text!)
        {
             //self.authenticateWithDigitsBeforeAccountCreation()
         
            self.userAccountViewModel.startProcessingUserSignup(self.signupUserNameTextField.text!,password: self.signupUserPasswordTextField.text!,email: self.emailIdField.text!){[weak self]res in
                
                if res{
                    
                    self!.presentProjectsViewController()
                }else{
                    self!.showAlertWithMessage("Signup failed!", message:"Please try again!")
                }
                
            }
        }
        else{
            self.showAlertWithMessage("Emailid invalid", message:"Please enter proper emailid")
        }
    }
    
    func authenticateWithDigitsBeforeAccountCreation()  {
        
        do{
            try self.userAccountViewModel.validateUserSignupCredentials(self.signupUserNameTextField.text!, password:self.signupUserPasswordTextField.text!, confirmPassword:self.signupUserConfirmPasswordTextField.text!)
            self.view.endEditing(true)
            
//            userAccountViewModel.makeTwoFactorAuthentication(self, userName: self.signupUserNameTextField.text!, password: self.signupUserPasswordTextField.text!,email: self.emailIdField.text!
//            )
        } catch LocalValidations.WeakUserName{self.showAlertWithMessage("Username invalid", message:"it must be atleast 3 characters long")}
        catch LocalValidations.ImproperUserName{self.showAlertWithMessage("Username invalid", message:"it should not contain white spaces")}
        catch LocalValidations.WeakPassword{self.showAlertWithMessage("Password invalid", message:"it must be atleast 8 characters long")}
        catch LocalValidations.PasswordMismatch{self.showAlertWithMessage("Error!", message:"password is not matching")}
        catch {}
        
    }

}
