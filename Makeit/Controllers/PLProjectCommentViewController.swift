//
//  PLProjectCommentViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import EventKitUI

class PLProjectCommentViewController: UITableViewController,EKEventEditViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet var commitmentNameTextField: UITextField!
    @IBOutlet var commitmentTargetDateTextField: UITextField!
    @IBOutlet weak var commitmentEndDateTextField: UITextField!
    @IBOutlet weak var commitmentPriorityTextField: UITextField!
    @IBOutlet var commitmentDescriptionTextView: UITextView!
    
    var pickerView:UIPickerView? = UIPickerView()
    var projectId:String!
    lazy  var commitmentViewModel:PLProjectCommentViewModel = {
        
        return PLProjectCommentViewModel()
    }()
    
    var commitmentDatePicker:UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView?.delegate = self
        self.pickerView?.dataSource = self
        commitmentPriorityTextField.inputView = pickerView
        
        addDoneBarButtonItem()
        commitmentDatePicker = UIDatePicker()
        commitmentDatePicker.datePickerMode = .Date
        self.commitmentTargetDateTextField.inputView = commitmentDatePicker
        self.commitmentEndDateTextField.inputView = commitmentDatePicker
        addDoneButtonToDatePicker()
        }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        commitmentPriorityTextField.text = "Critical"
        commitmentDatePicker.date = NSDate()
        self.commitmentNameTextField.becomeFirstResponder()
        if let _ = commitmentViewModel.commitment
        {
            if PLSharedManager.manager.isCalendarAccess{
                
                print("Cander Access is there")
                
            }else{
           commitmentNameTextField.text = commitmentViewModel.commitmentName()
           commitmentDescriptionTextView.text = commitmentViewModel.commitmentDescription()
           commitmentTargetDateTextField.text = commitmentViewModel.commitmentStartDate()
           commitmentEndDateTextField.text = commitmentViewModel.commitmentEndDate()
           self.navigationItem.rightBarButtonItem?.enabled = false
           self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clearColor()
            }
        }
        else{
               self.navigationItem.rightBarButtonItem?.tintColor = nil;
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
        commitmentEndDateTextField.inputAccessoryView = toolBar
        commitmentPriorityTextField.inputAccessoryView = toolBar
    }
    
    func performDone()
    {
        do{
            
            try commitmentViewModel.commitmentValidations(commitmentNameTextField.text!, startDate:commitmentDatePicker.date ,targetDate:commitmentDatePicker.date, description: commitmentDescriptionTextView.text)

            commitmentViewModel.createCommitmentWith(commitmentNameTextField.text!,startDate:commitmentDatePicker.date,targetDate: commitmentDatePicker.date, description: commitmentDescriptionTextView.text,projectId: projectId){ result in
                
                if result{
                    self.navigationController?.popViewControllerAnimated(true)
                }else {
                    print("Handle Error")
                }
            }
        }
        catch CommitValidation.NameEmpty{print("Empty Name")}
        catch CommitValidation.InvalidDate{print("Earlier date")}
        catch CommitValidation.DescriptionEmpty{print("Empty Description")}
        catch {}
    }

    func peformDateSelection()
    {
        if self.commitmentEndDateTextField.isFirstResponder(){
            
            self.commitmentEndDateTextField.resignFirstResponder()
            commitmentEndDateTextField.text = NSDateFormatter.localizedStringFromDate(commitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
            commitmentPriorityTextField.becomeFirstResponder()
        }else if self.commitmentTargetDateTextField.isFirstResponder(){
        self.commitmentTargetDateTextField.resignFirstResponder()
         commitmentTargetDateTextField.text = NSDateFormatter.localizedStringFromDate(commitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
           commitmentEndDateTextField.becomeFirstResponder()
        }
        else{
            
            self.commitmentPriorityTextField.resignFirstResponder()
            self.commitmentDescriptionTextView.becomeFirstResponder()
        }
    }
    
    func clearFields(){
        
        commitmentNameTextField.text = ""
        commitmentDescriptionTextView.text = ""
        commitmentTargetDateTextField.text = ""
        commitmentPriorityTextField.text = ""
        commitmentEndDateTextField.text = ""
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        commitmentViewModel.commitment = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func advancedCommitmentOptionsWithCalendar(sender: AnyObject)
    {
        
        let editViewController = EKEventEditViewController()
        editViewController.navigationController?.navigationItem.title = "Welcome"
        editViewController.eventStore = EKEventStore()
        editViewController.editViewDelegate = self
        self.presentViewController(editViewController, animated: true, completion:nil)
        
    }
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction){
       // self.fetchEvents(commitmentViewModel.eventStore)
       // print("'sdfgghghhj")
        self.dismissViewControllerAnimated(true, completion:nil)
    }
   
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return commitmentViewModel.priorityDataCount()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return commitmentViewModel.priorityTypeForRow(row)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
         commitmentPriorityTextField.text = commitmentViewModel.priorityTypeForRow(row)
        
    }
    
    
       
   }

