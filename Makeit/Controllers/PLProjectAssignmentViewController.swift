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
                    
                    print("PRAISE THE LORD")
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {print("Handle error")}
                
                
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
        
        return "SELECT ONE OR MORE ASSIGNEES"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == .Checkmark
        {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
            assignementViewModel.removeAssignee(indexPath.row)
            
        }
        else{
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            assignementViewModel.addAssignee(indexPath.row)
            
          }
        
        print(assignementViewModel.selectedAssigneeList)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
