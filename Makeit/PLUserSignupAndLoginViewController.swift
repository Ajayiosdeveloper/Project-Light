//  Project Light
//  ViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 12/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

let enableButtonColor = UIColor(colorLiteralRed: 11/255, green: 97/255, blue: 254/255, alpha: 1.0)
let kSignupTag = 0
let kLoginTag = 1

class PLUserSignupAndLoginViewController: UITableViewController,UITextFieldDelegate {
    //MARK: Login & Signup Screen View Objects
    @IBOutlet var loginUserNameTextField: UITextField!
    @IBOutlet var loginUserPasswordTextField: UITextField!
    @IBOutlet var userLogin: UIButton!
    @IBOutlet var signupUserNameTextField: UITextField!
    @IBOutlet var signupUserPasswordTextField: UITextField!
    @IBOutlet var signupUserConfirmPasswordTextField: UITextField!
    @IBOutlet var userSignup: UIButton!
    
    lazy private var userAccountViewModel:PLUserSignupAndLoginViewModel = {
          return PLUserSignupAndLoginViewModel()
    }()
    @IBOutlet var getStartedTableView: UITableView!
    var projectsViewController:PLProjectsViewController!
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        userLogin.enabled = false
        userSignup.enabled = false
      

    }
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loginUserPasswordTextField.text = ""
    }
    
    //MARK: UITextfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //Login fields first responder transfering
        if textField == loginUserNameTextField{
            if loginUserNameTextField.text?.characters.count > 0 {loginUserPasswordTextField.becomeFirstResponder()}
        }
        else if loginUserNameTextField.text?.characters.count > 0 && loginUserPasswordTextField.text?.characters.count > 0 {loginUserPasswordTextField.resignFirstResponder()}
        
        //Signup fields first responder transfering
        if textField == signupUserNameTextField{
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //Login button enabling & disabling
        if loginUserNameTextField.text?.characters.count > 0 && loginUserPasswordTextField.text?.characters.count > 0{userLogin.setTitleColor(enableButtonColor, forState: UIControlState.Normal); userLogin.enabled = true}
        else {userLogin.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal); userLogin.enabled = false}
       //Signup button enabling & disabling
        if signupUserNameTextField.text?.characters.count > 0 && signupUserPasswordTextField.text?.characters.count > 0 && signupUserConfirmPasswordTextField.text?.characters.count > 0
        {
           userSignup.setTitleColor(enableButtonColor, forState: UIControlState.Normal); userSignup.enabled = true
        }else{userSignup.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal); userSignup.enabled = false }
        
        return true
    }
    
    //MARK: Login & Signup Screen Actions
    
    @IBAction func loginUser(sender: AnyObject) {
     
     userAccountViewModel.addObserver(self, forKeyPath:"loginResultNotifier", options: NSKeyValueObservingOptions.New, context: nil)
     userAccountViewModel.validateUserLoginCredentials(loginUserNameTextField.text!,password: loginUserPasswordTextField.text!)
       
    }
    
    @IBAction func signupNewUser(sender: AnyObject) {
       do {
              userAccountViewModel.addObserver(self, forKeyPath: "signupResultNotifier", options: NSKeyValueObservingOptions.New, context:nil)
              try userAccountViewModel.validateUserSignupCredentials(signupUserNameTextField.text!, password:signupUserPasswordTextField.text!, confirmPassword:signupUserConfirmPasswordTextField.text!)
              self.view.endEditing(true)
        }
        catch LocalValidations.WeakUserName{showAlertWithMessage("Username invalid", message:"it must be atleast 3 characters long")}
        catch LocalValidations.ImproperUserName{showAlertWithMessage("Username invalid", message:"it should not contain white spaces")}
        catch LocalValidations.WeakPassword{showAlertWithMessage("Password invalid", message:"it must be atleast 8 characters long")}
        catch LocalValidations.PasswordMismatch{showAlertWithMessage("Error!", message:"password is not matching")}
        catch {}
    }
    
    func showAlertWithMessage(title:String,message:String)
    {
        if #available(iOS 9, *)
        {
            let alertController = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            alertController.addAction(action)
            self.presentViewController(alertController, animated:true, completion:nil)
        }
        else{
            let alert = UIAlertView(title: title, message: message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok") as UIAlertView
            alert.show()
         }
        
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == kSignupResultNotifier{
            handleStatus(change,tag:kSignupTag)
            removeObservationsOn(kSignupResultNotifier)
        }
        if keyPath == kLoginResultNotifier{
           handleStatus(change,tag:kLoginTag)
           removeObservationsOn(kLoginResultNotifier)
        }
    }
    
    func handleStatus(change:[String:AnyObject]?,tag:Int){
        
        if let _ = change, value = change![NSKeyValueChangeNewKey]{
            
            if value as! NSNumber == 1 { // Handling Alert Messages for Sign in
                if tag == 0{ clearTextfields()}
                
                presentProjectsViewController()
           }
            else{ // Handling Alert Messages for Login
                
                if tag == 0 {showAlertWithMessage("Failed!", message:"User name already exist.Please try another")}
                else{showAlertWithMessage("Error!", message:"Please try again")}
            }
        }
    }
    
    func removeObservationsOn(KeyPath:String){
        userAccountViewModel.removeObserver(self,forKeyPath:KeyPath)
    }
    
    func presentProjectsViewController(){
        
        if (projectsViewController == nil){
        
            projectsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("projectsViewController") as! PLProjectsViewController
        }
        if !(self.navigationController?.topViewController?.isKindOfClass(PLAddProjectViewController))!
        {
        
            self.navigationController?.pushViewController(projectsViewController, animated: false)

        }
        
    }
    
    func clearTextfields(){
      self.loginUserNameTextField.text = self.signupUserNameTextField.text
      self.signupUserNameTextField.text = ""; self.signupUserPasswordTextField.text = ""
      self.signupUserConfirmPasswordTextField.text = ""
    }
    
}


