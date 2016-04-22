//
//  PLProjectCommentViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLProjectCommentViewController: UITableViewController {
    
    @IBOutlet var commitmentNameTextField: UITextField!
    
    @IBOutlet var commitmentTargetDateTextField: UITextField!

    @IBOutlet var commitmentDescriptionTextView: UITextView!
    
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
    }

    func addDoneBarButtonItem(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target:self, action:#selector(PLAddProjectViewController.performDone))
    }
    
    func addDoneButtonToDatePicker()
    {
       let toolBar = UIToolbar()
       toolBar.barStyle = UIBarStyle.Default
       toolBar.sizeToFit()
       let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target:self, action: #selector(PLProjectCommentViewController.peformDateSelection))
        toolBar.items = [doneButton]
        commitmentTargetDateTextField.inputAccessoryView = toolBar
    }
    
    func performDone()
    {
        print("JESUS LOVES you")
        
        do{
            
            try commitmentViewModel.commitmentValidations(commitmentNameTextField.text!, targetDate:commitmentDatePicker.date, description: commitmentDescriptionTextView.text)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
}
