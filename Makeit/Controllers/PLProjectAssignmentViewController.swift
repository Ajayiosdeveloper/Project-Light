//
//  PLProjectAssignmentViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLProjectAssignmentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var assignmentNameTextFiled: UITextField!
    @IBOutlet var assignmenttargetDateTextField: UITextField!
    @IBOutlet var assigneeListTableView: UITableView!
    @IBOutlet weak var assignmentStartDateTextField: UITextField!
    @IBOutlet var assignmentDescriptionTextView: UITextView!
    
    var selectedIndexes = NSMutableArray()
    var projectId:String!
    var startDatecommitmentDatePicker:UIDatePicker!
    var targetDatecommitmentDatePicker:UIDatePicker!
    var assignementViewModel:PLProjectAssignmentViewModel!
    var profileViewController:PLUserProfileInfoTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(assignementViewModel.assigneeList)
        self.assigneeListTableView.registerNib(UINib(nibName:"PLAssigneeTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier: "Cell")
        addDoneBarButtonItem()
        startDatecommitmentDatePicker = UIDatePicker()
        startDatecommitmentDatePicker.datePickerMode = .DateAndTime
        self.assignmentStartDateTextField.inputView = startDatecommitmentDatePicker
        startDateDoneButtonToDatePicker()
        
        targetDatecommitmentDatePicker = UIDatePicker()
        targetDatecommitmentDatePicker.datePickerMode = .DateAndTime
        self.assignmenttargetDateTextField.inputView = targetDatecommitmentDatePicker
        targetDateDoneButtonToDatePicker()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = assignementViewModel, _ = assignementViewModel.assigneeList{
            
            assigneeListTableView.reloadData()
        }
        
        if let _ = assignementViewModel.selectedAssignment{
                assignmentNameTextFiled.text = assignementViewModel.assignmentName()
                assignmentStartDateTextField.text = assignementViewModel.assignmentStartDate()
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
        
            clearCellCheckMarks()
    }
 
    func addDoneBarButtonItem(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target:self, action:#selector(PLAddProjectViewController.performDone))
        
    }

    func performDone()
    {
       
        print("JESUS LOVES you")
        
        do{
            
            try assignementViewModel.assignmentValidations(assignmentNameTextFiled.text!,startDate:startDatecommitmentDatePicker.date ,targetDate: targetDatecommitmentDatePicker.date,description: assignmentDescriptionTextView.text,projectId: projectId,assignees:assignementViewModel.getSelectedAssigneeList())
            
            assignementViewModel.createAssignmentForProject(projectId, name:assignmentNameTextFiled.text! ,startDate: startDatecommitmentDatePicker.date, targetDate: targetDatecommitmentDatePicker.date, description: assignmentDescriptionTextView.text, assignees:assignementViewModel.getSelectedAssigneeList()){result in
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

    func startDateDoneButtonToDatePicker()
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target:self, action: #selector(PLProjectAssignmentViewController.dateSelection))
        toolBar.items = [doneButton]
        assignmentStartDateTextField.inputAccessoryView = toolBar
    }
    
    
    func dateSelection()
    {
        assignmentStartDateTextField.resignFirstResponder()
        assignmentStartDateTextField.text = NSDateFormatter.localizedStringFromDate(startDatecommitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        assignmenttargetDateTextField.becomeFirstResponder()
        
    }

    func targetDateDoneButtonToDatePicker()
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target:self, action: #selector(PLProjectAssignmentViewController.peformDateSelection))
        toolBar.items = [doneButton]
        assignmenttargetDateTextField.inputAccessoryView = toolBar
    }
    
    func peformDateSelection()
    {
        assignmenttargetDateTextField.resignFirstResponder()
        assignmenttargetDateTextField.text = NSDateFormatter.localizedStringFromDate(targetDatecommitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        assignmentDescriptionTextView.becomeFirstResponder()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0
        {
        return assignementViewModel.numbersOfRows()
        }
        return 0
    }
    
    
      func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! PLAssigneeTableViewCell
        cell.nameLabel.text = assignementViewModel.titleOfRowAtIndexPath(indexPath.row)
        cell.mailIdField.text = assignementViewModel.emailOfRowAtIndexPath(indexPath.row)
        cell.disclosureButton.tag = indexPath.row
       if PLSharedManager.manager.projectCreatedByUserId == QBSession.currentSession().currentUser?.ID
        {
            cell.disclosureButton.hidden = false
            cell.disclosureButton.addTarget(self, action: #selector(PLProjectAssignmentViewController.loadProfileController(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        }
        else
        {
            if assignementViewModel.isLoggedInUserPartOfAssignment()
            {
                if indexPath.row == 0
                {
                        cell.disclosureButton.hidden = true
                }
                else{
                    cell.disclosureButton.hidden = false
                    cell.disclosureButton.addTarget(self, action: #selector(PLProjectAssignmentViewController.loadProfileController(_:)), forControlEvents:UIControlEvents.TouchUpInside)
                    }
            }
            else
            {
             cell.disclosureButton.hidden = false
                cell.disclosureButton.addTarget(self, action: #selector(PLProjectAssignmentViewController.loadProfileController(_:)), forControlEvents:UIControlEvents.TouchUpInside)
            }          
        }
        assignementViewModel.contributorImageRowAtIndexPath(indexPath.row, completion: { (avatar) in
            
            if let _ = avatar{
                
                cell.profilePicture.image = avatar!
                cell.profilePicture.layer.masksToBounds = true
            }else{
                
                cell.profilePicture.image = UIImage(named:"UserImage.png")
            }
        })
        
        if selectedIndexes.containsObject(indexPath){
            cell.accessoryType = .Checkmark
        }else{
            cell.accessoryType = .None
        }
        
        if assignementViewModel.selectedAssignment == nil{
            cell.statueField.text = ""
        }
   
        return cell
     
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0
        {
        if assignementViewModel.selectedAssignment != nil
        {
            return "ASSIGNED TO"
        }
        
        return "SELECT ONE OR MORE ASSIGNEES"
        }
        return nil
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let footerView:UIView! = UIView(frame:CGRectMake(0,0,self.view.frame.size.width,20))
        if section == 1
        {
            if assignementViewModel.selectedAssignment != nil{
                
                footerView.backgroundColor = UIColor(colorLiteralRed: 89/255, green: 181/255, blue: 50/255, alpha: 1)
                footerView.layer.cornerRadius = 15
                footerView.clipsToBounds = true
                
                let userId = QBSession.currentSession().currentUser?.ID
                if userId! == PLSharedManager.manager.projectCreatedByUserId{
                    
                    self.addButtonForTableViewFooterOnView(footerView, title: "Close", tag: -1)
                    
                }else{
                    
                    if assignementViewModel.isLoggedInUserPartOfAssignment()
                    {
                        self.addButtonForTableViewFooterOnView(footerView, title: "Completed ?", tag: 1)
                    }
                    else{
                        return nil
                    }
                }

        }
        return footerView
    }
    return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if assignementViewModel.selectedAssignment == nil
        {
            
            if selectedIndexes.containsObject(indexPath){
                
                selectedIndexes.removeObject(indexPath)
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
                assignementViewModel.removeAssignee(indexPath.row)
            }else{
                selectedIndexes.addObject(indexPath)
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
                assignementViewModel.addAssignee(indexPath.row)
            }
        }
     }
    
    func addButtonForTableViewFooterOnView(addOnView:UIView,title:String,tag:Int)
    {
        let addMemberButton = UIButton(type:.Custom)
        addMemberButton.tag = tag
        addMemberButton.setTitle(title, forState: UIControlState.Normal)
        addMemberButton.titleLabel?.font = UIFont(name:"Avenir Next Demi Bold ", size: 24)
        addMemberButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        addMemberButton.addTarget(self, action:#selector(PLProjectAssignmentViewController.performButtonActionOfFooterView), forControlEvents: UIControlEvents.TouchUpInside)
        addMemberButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 40)
        addMemberButton.contentHorizontalAlignment = .Center
        addMemberButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        addOnView.addSubview(addMemberButton)
    }

    func performButtonActionOfFooterView(sender:UIButton){
        print(sender.tag)
        print("PRAISE THE LORD")
        if sender.tag == 1{
            
            assignementViewModel.updateAssigmentStatusOfLoggedInUser()
            
        }
        else{
            
            
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
       assignmentStartDateTextField.text = ""
       assignmentDescriptionTextView.text = ""
    }
   
    func clearCellCheckMarks(){
        
        for cell in self.assigneeListTableView.visibleCells{
            
            cell.accessoryType = .None
        }
    }
    
    func loadProfileController(sender : UIButton)
    {
        print("cell \(sender.tag)")
        
        profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLUserProfileInfoTableViewController") as? PLUserProfileInfoTableViewController
        profileViewController.disablingBtn = false
        profileViewController.userProfileModel = PLUserProfileInfoViewModel()
        let userId = assignementViewModel.getSelectedAssigneeUserId(sender.tag)
        profileViewController.fetchingUserDetails(userId)
        self.navigationController!.pushViewController(profileViewController!, animated: true)

   
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        assignementViewModel.selectedAssignment = nil
        selectedIndexes = []
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
