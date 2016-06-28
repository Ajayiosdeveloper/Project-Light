//
//  PLUserProfileInfoTableViewController.swift
//  Makeit
//
//  Created by Tharani P on 06/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

protocol DataTransform: class
{
    func selectedAssignment(assignment: PLAssignment)
}

class PLUserProfileInfoTableViewController: UITableViewController,UITextFieldDelegate,UIAlertViewDelegate
{
    @IBOutlet var phoneNumber: UITextField!
    @IBOutlet weak var dateOfBirth: UITextField!
    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var experience: UITextField!
    @IBOutlet weak var technology: UITextField!
    @IBOutlet weak var updateProfileButton: UIButton!
    
    weak var delegate : DataTransform!
    var disablingBtn : Bool = true
    var selectedAssignment : PLAssignment!
    var userProfileModel = PLUserProfileInfoViewModel()
    var dobPicker:UIDatePicker!
    var userName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if userName != ""
        {
            self.title = userName
        }
        updateProfileButton.hidden = false
        dobPicker = UIDatePicker()
        dobPicker.datePickerMode = .Date
        self.dateOfBirth.inputView = dobPicker
        addDoneButtonToDatePicker()
    }
   
    override func viewWillAppear(animated: Bool)
    {
        if !disablingBtn
        {
           updateProfileButton.hidden = true
           enableAndDisabledisableAllFields(false)
        }
        else{
             updateProfileButton.hidden = false
             enableAndDisabledisableAllFields(true)
            self.fetchingUserDetails((QBSession.currentSession().currentUser?.ID)!)

        }
    }
    
    func fetchingUserDetails(userId : UInt)
     {
       userProfileModel.getUserProfileDetail(userId) { dict,err in

         if let _ = dict
         {
            self.dateOfBirth.text = dict!["dateOfBirth"] as? String
            self.emailId.text = dict!["emailId"] as? String
            self.phoneNumber.text = dict!["phoneNumber"] as? String
            self.technology.text = dict!["technology"] as? String
            self.experience.text = dict!["experience"] as? String
            self.companyName.text = dict!["companyName"] as? String
            self.designation.text = dict!["designation"] as? String
          }
        }
    }
    
    func enableAndDisabledisableAllFields(flag:Bool)
    {
        dateOfBirth.enabled = flag
        emailId.enabled = flag
        companyName.enabled = flag
        designation.enabled = flag
        experience.enabled = flag
        technology.enabled = flag
        phoneNumber.enabled = flag
    }

    func addDoneButtonToDatePicker()
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target:self, action: #selector(PLUserProfileInfoTableViewController.peformDateSelection))
        toolBar.items = [doneButton]
        dateOfBirth.inputAccessoryView = toolBar
    }
    
    func peformDateSelection()
    {
        dateOfBirth.resignFirstResponder()
        dateOfBirth.text = NSDateFormatter.localizedStringFromDate(dobPicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)

    }
   
    func textFieldDidEndEditing(textField: UITextField) {
        self.validatePhoneNumber()
    }
    
    func validatePhoneNumber() -> Bool
    {
        if phoneNumber.text == ""
        {
            if #available(iOS 8.0, *)
            {
                let alertView = UIAlertController.init(title: "Invalid phone number", message: "Phone number should not be empty", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Ok", style: .Default , handler: nil)
                alertView.addAction(okAction)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
            else
            {
                let alertView = UIAlertView(title: "Invalid phone number", message: "Phone number should not be empty", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Ok")
                alertView.show()
            }
        return false
        }
        else if phoneNumber.text?.characters.count < 10
        {
            if #available(iOS 8.0, *)
            {
                let alertView = UIAlertController.init(title: "Invalid phone number", message: "Aleast enter 10 digits", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Ok", style: .Default , handler: nil)
                alertView.addAction(okAction)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
            else
            {
                let alertView = UIAlertView(title: "Invalid phone number", message: "Aleast enter 10 digits", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Ok")
                alertView.show()
            }
            return false
        }
        else if phoneNumber.text?.characters.count > 12
        {
            if #available(iOS 8.0, *)
            {
                let alertView = UIAlertController.init(title: "Invalid phone number", message: "Phone number should be 10 to 12 digits", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Ok", style: .Default , handler: nil)
                alertView.addAction(okAction)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
            else
            {
                let alertView = UIAlertView(title: "Invalid phone number", message: "Phone number should be 10 to 12 digits", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Ok")
                alertView.show()
            }
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func updateUserProfile(sender: AnyObject)
    {
        if validatePhoneNumber()
        {
        userProfileModel.createUserProfileWith(dobPicker.date, companyName: companyName.text, technology: technology.text, experience: self.experience.text , designation: designation.text, emailId : emailId.text,phoneNumber: phoneNumber.text) { (result,err) in
            if result
            {
                self.navigationController?.popViewControllerAnimated(true)
            }
            else{
                print("Error while updating the users profile")
             }
           }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidAppear(true)
        if selectedAssignment != nil{
            delegate.selectedAssignment(selectedAssignment)
        }
    }
}
