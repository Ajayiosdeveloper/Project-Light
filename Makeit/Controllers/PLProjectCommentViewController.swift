//
//  PLProjectCommentViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import EventKitUI

class PLProjectCommentViewController: UITableViewController,EKEventEditViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource
{
    
    @IBOutlet var commitmentNameTextField: UITextField!
    @IBOutlet var commitmentTargetDateTextField: UITextField!
    @IBOutlet weak var commitmentEndDateTextField: UITextField!
    @IBOutlet weak var commitmentPriorityTextField: UITextField!
    @IBOutlet var commitmentDescriptionTextView: UITextView!
    @IBOutlet weak var isTaskCompleted: UISwitch!
    @IBOutlet weak var taskCompletedLabel: UILabel!
    
    var doneButton:UIBarButtonItem!
    var pickerView:UIPickerView? = UIPickerView()
    var projectId:String!
    lazy  var commitmentViewModel:PLProjectCommentViewModel = {
        
        return PLProjectCommentViewModel()
    }()
    
    var startDatecommitmentDatePicker:UIDatePicker!
    var targetDatecommitmentDatePicker:UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = commitmentViewModel.commitmentName()
        self.pickerView?.delegate = self
        self.pickerView?.dataSource = self
        commitmentPriorityTextField.inputView = pickerView
        commitmentPriorityTextField.text = "Critical"
        addDoneBarButtonItem()
        startDatecommitmentDatePicker = UIDatePicker()
        startDatecommitmentDatePicker.datePickerMode = .DateAndTime
        self.commitmentTargetDateTextField.inputView = startDatecommitmentDatePicker
        startDateDoneButtonToDatePicker()
        targetDatecommitmentDatePicker = UIDatePicker()
        targetDatecommitmentDatePicker.datePickerMode = .DateAndTime
        self.commitmentEndDateTextField.inputView = targetDatecommitmentDatePicker
        targetDateDoneButtonToDatePicker()
       }
    
      override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)

        if let _ = commitmentViewModel.commitment
        {
            if PLSharedManager.manager.isCalendarAccess{
                
                print("Cander Access is there")
                
            }else{
                isTaskCompleted.hidden = false
                taskCompletedLabel.hidden = false
                commitmentNameTextField.text = commitmentViewModel.commitmentName()
                commitmentDescriptionTextView.text = commitmentViewModel.commitmentDescription()
                commitmentTargetDateTextField.text = commitmentViewModel.commitmentStartDate()
                commitmentEndDateTextField.text = commitmentViewModel.commitmentEndDate()
                if commitmentViewModel.commitmentStatus() == 0{
                    isTaskCompleted.enabled = true
                    isTaskCompleted.on = false
                    self.doneButton.enabled = true
                    self.doneButton.width = 0
                }
                else{
                    isTaskCompleted.enabled = false
                    isTaskCompleted.on = true
                    self.navigationItem.rightBarButtonItem?.enabled = false
                    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clearColor()
                }
                
            }
            
            self.view.endEditing(true)
        }
        else{
            self.commitmentNameTextField.becomeFirstResponder()
            self.navigationItem.rightBarButtonItem?.tintColor = nil;
            clearFields()
            self.navigationItem.rightBarButtonItem?.enabled = true
            doneButton.width = 0
            isTaskCompleted.hidden = true
            taskCompletedLabel.hidden = true
        }
    }

    @IBAction func taskCompletedAction(sender: UISwitch) {

        if sender.on
        {
            commitmentViewModel.updateCommitmentStatus(){(res) in
                if res{
                    self.isTaskCompleted.enabled = false
                }
            }
        }
    }
    
    func startDateDoneButtonToDatePicker()
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target:self, action: #selector(PLProjectCommentViewController.dateSelection))
        toolBar.items = [doneButton]
        commitmentTargetDateTextField.inputAccessoryView = toolBar
    }
    
    
    func dateSelection()
    {
        commitmentTargetDateTextField.resignFirstResponder()
        commitmentTargetDateTextField.text = NSDateFormatter.localizedStringFromDate(startDatecommitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        commitmentEndDateTextField.becomeFirstResponder()
    }
    
    func targetDateDoneButtonToDatePicker()
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target:self, action: #selector(PLProjectCommentViewController.peformTargetDateSelection))
        toolBar.items = [doneButton]
        commitmentEndDateTextField.inputAccessoryView = toolBar
    }
    
    func peformTargetDateSelection()
    {
        commitmentEndDateTextField.resignFirstResponder()
        commitmentEndDateTextField.text = NSDateFormatter.localizedStringFromDate(targetDatecommitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        commitmentPriorityTextField.becomeFirstResponder()
    }

   
    func addDoneBarButtonItem(){
        
        doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target:self, action:#selector(PLProjectCommentViewController.performDone))

        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func addBackBarButtonItem(){
        
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target:self, action:#selector(PLProjectCommentViewController.performCancel))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func performCancel()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func performDone()
    {
        print("done btn")

        do{
            
            try commitmentViewModel.commitmentValidations(commitmentNameTextField.text!, startDate:startDatecommitmentDatePicker.date ,targetDate:targetDatecommitmentDatePicker.date, description: commitmentDescriptionTextView.text)
            if commitmentViewModel.commitment == nil{
            commitmentViewModel.createCommitmentWith(commitmentNameTextField.text!,startDate:startDatecommitmentDatePicker.date,targetDate: targetDatecommitmentDatePicker.date, description: commitmentDescriptionTextView.text,projectId: projectId){ result in
            
                if result{
                    print("updated")
                    self.navigationController?.popViewControllerAnimated(true)
                }else {
                    print("Handle Error")
                }
            }
            }else{
                
                commitmentViewModel.updateCommitmentWith(commitmentNameTextField.text!, startDate:startDatecommitmentDatePicker.date ,targetDate:targetDatecommitmentDatePicker.date, description: commitmentDescriptionTextView.text,projectId: projectId) { res in
                    
                    
                }
                
              
              
              //  self.dismissViewControllerAnimated(true, completion: nil)
               
            }
       
        
        }
        catch CommitValidation.NameEmpty{print("Empty Name")}
        catch CommitValidation.InvalidDate{print("Earlier date")}
        catch CommitValidation.DescriptionEmpty{print("Empty Description")}
        catch {}
   }
    
    func clearFields(){
        self.title = ""
        commitmentNameTextField.text = ""
        commitmentTargetDateTextField.text = ""
        commitmentEndDateTextField.text = ""
        commitmentDescriptionTextView.text = ""
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
        self.dismissViewControllerAnimated(true, completion:nil)
    }
   
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return commitmentViewModel.priorityDataCount()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return commitmentViewModel.priorityTypeForRow(row)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
         commitmentPriorityTextField.text = commitmentViewModel.priorityTypeForRow(row)
    }
 }

