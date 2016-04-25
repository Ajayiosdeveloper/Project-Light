//
//  PLProjectAssignmentViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLProjectAssignmentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var assignmentNameTextFiled: UITextField!
   
    @IBOutlet var assignmenttargetDateTextField: UITextField!
    
    @IBOutlet var assigneeListTableView: UITableView!
    
   
    @IBOutlet var assignmentDescriptionTextView: UITextView!
    var projectId:String!
    var commitmentDatePicker:UIDatePicker!
    var assignementViewModel:PLProjectAssignmentViewModel!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(assignementViewModel.assigneeList)

        addDoneBarButtonItem()
        commitmentDatePicker = UIDatePicker()
        commitmentDatePicker.datePickerMode = .Date
        self.assignmenttargetDateTextField.inputView = commitmentDatePicker
        addDoneButtonToDatePicker()
       
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = assignementViewModel, _ = assignementViewModel.assigneeList{
            
            assigneeListTableView.reloadData()
        }
        
        if let _ = assignementViewModel.selectedAssignment{
                assignmentNameTextFiled.text = assignementViewModel.assignmentName()
                assignmenttargetDateTextField.text = assignementViewModel.assignmentTargetDate()
                assignmentDescriptionTextView.text = assignementViewModel.assignmentDescription()
                self.navigationItem.rightBarButtonItem?.enabled = false
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clearColor()
                assignementViewModel.responsibleForAssigniment()
                assigneeListTableView.reloadData()
                assigneeListTableView.allowsSelection = false
                }else {self.navigationItem.rightBarButtonItem?.enabled = true ;
                self.navigationItem.rightBarButtonItem?.tintColor = nil;
                assigneeListTableView.allowsSelection = true
               clearFields()
            }

    }
 
    func addDoneBarButtonItem(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target:self, action:#selector(PLAddProjectViewController.performDone))
    }

    func performDone()
    {
       
        print("JESUS LOVES you")
        
        do{
            
            try assignementViewModel.assignmentValidations(assignmentNameTextFiled.text!,targetDate: commitmentDatePicker.date,description: assignmentDescriptionTextView.text,projectId: projectId,assignees:assignementViewModel.getSelectedAssigneeList())
            
            assignementViewModel.createAssignmentForProject(projectId, name:assignmentNameTextFiled.text! , targetDate: commitmentDatePicker.date, description: assignmentDescriptionTextView.text, assignees:assignementViewModel.getSelectedAssigneeList()){result in
                if result{
                  dispatch_async(dispatch_get_main_queue(), {
                        
                        self.navigationController?.popViewControllerAnimated(true)
                  })
                    
                }
                else {
                
                }
            }
        }
        catch AssignmentValidation.NameEmpty{print("Empty Name")}
        catch AssignmentValidation.InvalidDate{print("Earlier date")}
        catch AssignmentValidation.DescriptionEmpty{print("Empty Description")}
        catch AssignmentValidation.NoAssignee{print("No Assignee")}
        catch {}
        
      
    }

    func addDoneButtonToDatePicker()
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target:self, action: #selector(PLProjectAssignmentViewController.peformDateSelection))
        toolBar.items = [doneButton]
        assignmenttargetDateTextField.inputAccessoryView = toolBar
    }

    func peformDateSelection()
    { assignmenttargetDateTextField.resignFirstResponder()
      assignmenttargetDateTextField.text = NSDateFormatter.localizedStringFromDate(commitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        assignmentDescriptionTextView.becomeFirstResponder()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return assignementViewModel.numbersOfRows()
        
    }
    
      func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        cell.textLabel?.text = assignementViewModel.titleOfRowAtIndexPath(indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if assignementViewModel.selectedAssignment != nil
        {
            return "ASSIGNED TO"
        }
        
        return "SELECT ONE OR MORE ASSIGNEES"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if assignementViewModel.selectedAssignment == nil
        {
        
        if tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == .Checkmark
        {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
            assignementViewModel.removeAssignee(indexPath.row)
            
        }
        else{
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            assignementViewModel.addAssignee(indexPath.row)
            
          }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearFields()
    {
       assignmentNameTextFiled.text = ""
       assignmenttargetDateTextField.text = ""
       assignmentDescriptionTextView.text = ""
        
    }
   
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        assignementViewModel.selectedAssignment = nil
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
