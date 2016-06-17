//
//  PLUserLoginViewController.swift
//  Makeit
//
//  Created by Tharani P on 11/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

let enableButtonColor = UIColor(colorLiteralRed: 11/255, green: 97/255, blue: 254/255, alpha: 1.0)
let kSignupTag = 0
let kLoginTag = 1

class PLUserLoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet var forgotPasswordField: UIButton!
    @IBOutlet weak var loginUserNameTextField: UITextField!
    @IBOutlet weak var userLogin: UIButton!
    @IBOutlet weak var loginUserPasswordTextField: UITextField!
    
    lazy private var userAccountViewModel:PLUserSignupAndLoginViewModel = {
        return PLUserSignupAndLoginViewModel()
    }()
    
    var projectsViewController:PLProjectsViewController!
    var sideBarRootViewController:PLSidebarRootViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLogin.enabled = false
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loginUserPasswordTextField.text = ""
        loginUserNameTextField.becomeFirstResponder()
        PLDynamicEngine.animateTextfield(loginUserNameTextField)
        PLDynamicEngine.animateTextfield(loginUserPasswordTextField)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //Login fields first responder transfering
        if textField == loginUserNameTextField{
            if loginUserNameTextField.text?.characters.count > 0 {loginUserPasswordTextField.becomeFirstResponder()}
        }
        else if loginUserNameTextField.text?.characters.count > 0 && loginUserPasswordTextField.text?.characters.count > 0 {loginUserPasswordTextField.resignFirstResponder()}
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //Login button enabling & disabling
        if loginUserNameTextField.text?.characters.count > 0 && loginUserPasswordTextField.text?.characters.count > 0
        {
            userLogin.setTitleColor(enableButtonColor, forState: UIControlState.Normal); userLogin.enabled = true
        }
        else {
            userLogin.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal); userLogin.enabled = false
        }
        return true
    }

     //MARK: Login & Signup Screen Actions
    @IBAction func loginUser(sender: UIButton)
    {
        PLDynamicEngine.animateButton(userLogin)
        
        userAccountViewModel.addObserver(self, forKeyPath:"loginResultNotifier", options: NSKeyValueObservingOptions.New, context: nil)
        userAccountViewModel.validateUserLoginCredentials(loginUserNameTextField.text!, password: loginUserPasswordTextField.text!) { (err) in
            if let _ = err
            {
                PLSharedManager.showAlertIn(self, error: err!, title: "Login Failed", message: "Please provide correct details")
            }
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
            let alert = UIAlertView(title: title, message: message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok") as UIAlertView
            alert.show()

            // Fallback on earlier versions
        }
        
        
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
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
        
        if (projectsViewController == nil)
        {
                sideBarRootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLSidebarRootViewController") as! PLSidebarRootViewController
        }
        self.presentViewController(sideBarRootViewController, animated: true, completion:nil)
    }
    
    func clearTextfields(){
        self.loginUserNameTextField.text = ""
        
    }

    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue) {
   
    }
    
    @IBAction func SignUpUser(sender: AnyObject) {
    
        let signUpViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PLUserSignUpViewController")
        self.presentViewController(signUpViewController, animated: true, completion: nil)
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
       
        let forgotPassword:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PLResetPasswordViewController")
        self.presentViewController(forgotPassword, animated: true, completion: nil)

    }
}
