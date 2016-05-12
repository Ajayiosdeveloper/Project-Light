//
//  PLProjectCommentViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import EventKitUI

class PLProjectCommentViewController: UITableViewController,EKEventEditViewDelegate {
    
    //
    @IBOutlet weak var editCommitmentButton: UIButton!
    
    @IBOutlet var commitmentNameTextField: UITextField!
    
    @IBOutlet var commitmentTargetDateTextField: UITextField!

    @IBOutlet var commitmentDescriptionTextView: UITextView!
    
    @IBOutlet weak var calendarSwitch: UISwitch!
    
    var isSwitchOn = false
    var editCommitment = false
    
    var projectId:String!
   
    lazy  var commitmentViewModel:PLProjectCommentViewModel = {
        
        return PLProjectCommentViewModel()
    }()
    
    var commitmentDatePicker:UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        addDoneBarButtonItem()
        commitmentDatePicker = UIDatePicker()
        commitmentDatePicker.datePickerMode = .Date
        self.commitmentTargetDateTextField.inputView = commitmentDatePicker
        addDoneButtonToDatePicker()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        commitmentDatePicker.date = NSDate()
        self.commitmentNameTextField.becomeFirstResponder()
        if let _ = commitmentViewModel.commitment
        {  editCommitment = true
           commitmentNameTextField.text = commitmentViewModel.commitmentName()
           commitmentDescriptionTextView.text = commitmentViewModel.commitmentDescription()
           commitmentTargetDateTextField.text = commitmentViewModel.commitmentTargetDate()
           self.navigationItem.rightBarButtonItem?.enabled = false
           self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clearColor()
           editCommitmentButton.enabled = true
           editCommitmentButton.setAttributedTitle(NSAttributedString(string: "Edit Commitment"), forState: UIControlState.Normal)
            calendarSwitch.hidden = true
        
        }else if !editCommitment{self.navigationItem.rightBarButtonItem?.enabled = true ;
               self.navigationItem.rightBarButtonItem?.tintColor = nil;
              editCommitmentButton.enabled = false
              calendarSwitch.hidden = false
              editCommitmentButton.setTitle("", forState: UIControlState.Normal)
               clearFields()
        }
    }

    func addDoneBarButtonItem(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target:self, action:#selector(PLAddProjectViewController.performDone))
    }
    
    func addDoneButtonToDatePicker()
    {
       let toolBar = UIToolbar()
       toolBar.barStyle = UIBarStyle.Default
       toolBar.sizeToFit()
       let  doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target:self, action: #selector(PLProjectCommentViewController.peformDateSelection))
        toolBar.items = [doneButton]
        commitmentTargetDateTextField.inputAccessoryView = toolBar
    }
    
    func performDone()
    {
        print("JESUS LOVES you")
        
        do{
            
            try commitmentViewModel.commitmentValidations(commitmentNameTextField.text!, targetDate:commitmentDatePicker.date, description: commitmentDescriptionTextView.text)
            if isSwitchOn{
                commitmentViewModel.addCommitmentToCalendar(commitmentNameTextField.text!, date: commitmentDatePicker.date)
            }
            
            commitmentViewModel.createCommitmentWith(commitmentNameTextField.text!,targetDate: commitmentDatePicker.date,description: commitmentDescriptionTextView.text,projectId: projectId){ result in
                
                if result{
                    self.navigationController?.popViewControllerAnimated(true)
                }else {print("Handle Error")}
            }
        }
        catch CommitValidation.NameEmpty{print("Empty Name")}
        catch CommitValidation.InvalidDate{print("Earlier date")}
        catch CommitValidation.DescriptionEmpty{print("Empty Description")}
        catch {}
    }

    func peformDateSelection()
    {
        self.commitmentTargetDateTextField.resignFirstResponder()
         commitmentTargetDateTextField.text = NSDateFormatter.localizedStringFromDate(commitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        commitmentDescriptionTextView.becomeFirstResponder()
    }
    
    func clearFields(){
        
        commitmentNameTextField.text = ""
        commitmentDescriptionTextView.text = ""
        commitmentTargetDateTextField.text = ""
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        commitmentViewModel.commitment = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func advancedCommitmentOptionsWithCalendar(sender: AnyObject) {
        
        let editViewController = EKEventEditViewController()
        editCommitment = true
        editViewController.eventStore = EKEventStore()
        editViewController.editViewDelegate = self
        self.presentViewController(editViewController, animated: true, completion:nil)
    }
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction){
        print(controller.event)
        self.dismissViewControllerAnimated(true, completion:nil)
    }
   
    @IBAction func addCommitmentToCalendar(sender: UISwitch) {
       
        if sender.on{
            isSwitchOn = true
        }else{
            isSwitchOn = false
        }
      }
    
    
}
