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
    
    var startDatecommitmentDatePicker:UIDatePicker!
    var targetDatecommitmentDatePicker:UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView?.delegate = self
        self.pickerView?.dataSource = self
        commitmentPriorityTextField.inputView = pickerView
        commitmentPriorityTextField.text = "Critical"
        addDoneBarButtonItem()
        startDatecommitmentDatePicker = UIDatePicker()
        startDatecommitmentDatePicker.datePickerMode = .Date
        self.commitmentTargetDateTextField.inputView = startDatecommitmentDatePicker
        startDateDoneButtonToDatePicker()
        targetDatecommitmentDatePicker = UIDatePicker()
        targetDatecommitmentDatePicker.datePickerMode = .Date
        self.commitmentEndDateTextField.inputView = targetDatecommitmentDatePicker
        targetDateDoneButtonToDatePicker()
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
        commitmentTargetDateTextField.text = NSDateFormatter.localizedStringFromDate(startDatecommitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
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
        commitmentEndDateTextField.text = NSDateFormatter.localizedStringFromDate(targetDatecommitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        commitmentPriorityTextField.becomeFirstResponder()
    }

     override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
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
    
    func performDone()
    {
        do{
            
            try commitmentViewModel.commitmentValidations(commitmentNameTextField.text!, startDate:startDatecommitmentDatePicker.date ,targetDate:targetDatecommitmentDatePicker.date, description: commitmentDescriptionTextView.text)

            commitmentViewModel.createCommitmentWith(commitmentNameTextField.text!,startDate:startDatecommitmentDatePicker.date,targetDate: targetDatecommitmentDatePicker.date, description: commitmentDescriptionTextView.text,projectId: projectId){ result in
                
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
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return commitmentViewModel.priorityTypeForRow(row)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
         commitmentPriorityTextField.text = commitmentViewModel.priorityTypeForRow(row)
    }
 }

