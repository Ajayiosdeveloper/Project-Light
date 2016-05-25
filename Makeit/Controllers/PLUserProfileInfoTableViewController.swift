//
//  PLUserProfileInfoTableViewController.swift
//  Makeit
//
//  Created by Tharani P on 06/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLUserProfileInfoTableViewController: UITableViewController,UITextFieldDelegate
{
    @IBOutlet weak var dateOfBirth: UITextField!
    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var experience: UITextField!
    @IBOutlet weak var technology: UITextField!
    @IBOutlet weak var updateProfileButton: UIButton!

    var disablingBtn : Bool = true
    
    var userProfileModel = PLUserProfileInfoViewModel()
    var dobPicker:UIDatePicker!
        
    override func viewDidLoad() {
        super.viewDidLoad()
       
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
        }
            userProfileModel.getUserProfileDetail { dict in
            print("Output")
            
            if let _ = dict{
                
               self.dateOfBirth.text = dict!["dateOfBirth"] as? String
                 self.emailId.text = dict!["emailId"] as? String
                 self.technology.text = dict!["technology"] as? String
                 self.experience.text = dict!["experience"] as? String
                 self.companyName.text = dict!["companyName"] as? String
                 self.designation.text = dict!["designation"] as? String
            
            }else{
                
                print("No data found")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func updateUserProfile(sender: AnyObject)
    {
        print("Update User Profile")
       
        userProfileModel.createUSerProfileWith(dobPicker.date, companyName: companyName.text, technology: technology.text, experience: self.experience.text , designation: designation.text, emailId : emailId.text) { (result) in
            if result
            {
                self.navigationController?.popViewControllerAnimated(true)
            }
            else{
                print("Error while updating the users profile")
            }
        
        }
    }
    
    func addBackBarButtonItem(){
        
        let backButton = UIBarButtonItem(barButtonSystemItem:.Cancel, target: self, action: #selector(PLUserProfileInfoTableViewController.performCancel))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func performCancel()
    {
     print("Cancel")
    }
}
