//
//  PLProjectAssignmentViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLProjectAssignmentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,DataTransform {

    @IBOutlet var completeStatusLabel: UILabel!
    @IBOutlet var assignmentStatusSlider: UISlider!
    @IBOutlet var assignmentNameTextFiled: UITextField!
    @IBOutlet var assignmenttargetDateTextField: UITextField!
    @IBOutlet var assigneeListTableView: UITableView!
    @IBOutlet weak var assignmentStartDateTextField: UITextField!
    @IBOutlet var assignmentDescriptionTextView: UITextView!
    var plPopOverController:WYPopoverController?
    var  diplayMembersPopover:PLDisplayMembersPopover!
    
    var selectedIndexes = NSMutableArray()
    var projectId:String!
    var startDatecommitmentDatePicker:UIDatePicker!
    var targetDatecommitmentDatePicker:UIDatePicker!
    var assignmentViewModel:PLProjectAssignmentViewModel!
    var profileViewController:PLUserProfileInfoTableViewController!
    var assignmentStatus:UIButton!
    var headerView:UIView!
    var refreshFlag = true
    var headerColor = UIColor(colorLiteralRed: 89/255, green: 181/255, blue: 50/255, alpha: 1)
    var loggedInUserStatus = "0"
    var isSliderValueChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        print(assignmentViewModel.assigneeList)
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
      
        if let _ = assignmentViewModel, _ = assignmentViewModel.assigneeList{
            
            assigneeListTableView.reloadData()
            
        }
        
        if let _ = assignmentViewModel.selectedAssignment{
            
               self.title = assignmentViewModel.assignmentName()
                assignmentNameTextFiled.text = assignmentViewModel.assignmentName()
                assignmentStartDateTextField.text = assignmentViewModel.assignmentStartDate()
                assignmenttargetDateTextField.text = assignmentViewModel.assignmentTargetDate()
                assignmentDescriptionTextView.text = assignmentViewModel.assignmentDescription()
             if PLSharedManager.manager.projectCreatedByUserId == PLSharedManager.manager.loggedInUserId{
                completeStatusLabel.hidden = true
                assignmentStatusSlider.hidden = true
             }else{
                
                completeStatusLabel.hidden = false
                assignmentStatusSlider.hidden = false
                isSliderValueChanged = false
              }
            
                self.navigationItem.rightBarButtonItem?.enabled = false
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clearColor()
              if refreshFlag{
              assignmentViewModel.responsibleForAssigniment(){[weak self]result,err in
                
                if result{
                    self!.completeStatusLabel.text = "\(self!.assignmentViewModel.showPercentageCompletedInSlider()) % Done"
                    self!.assignmentStatusSlider.value = Float(self!.assignmentViewModel.showPercentageCompletedInSlider())
                    self!.assigneeListTableView.reloadData()
                    self!.assigneeListTableView.allowsSelection = false
                  }
                else
                {
                    PLSharedManager.showAlertIn(self!, error: err!, title: "Assignee list not avaliable", message: "")
                }
                }
             }
            
          }
           else {
           
               self.navigationItem.rightBarButtonItem?.enabled = true ;
                self.navigationItem.rightBarButtonItem?.tintColor = nil;
                assigneeListTableView.allowsSelection = true
              completeStatusLabel.hidden = true
              assignmentStatusSlider.hidden = true
               clearFields()
          }
        
            clearCellCheckMarks()
    }
 
    func addDoneBarButtonItem(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target:self, action:#selector(PLAddProjectViewController.performDone))
        
    }

    func performDone()
    {
        do{
            
            try assignmentViewModel.assignmentValidations(assignmentNameTextFiled.text!,startDate:startDatecommitmentDatePicker.date ,targetDate: targetDatecommitmentDatePicker.date,description: assignmentDescriptionTextView.text,projectId: projectId,assignees:assignmentViewModel.getSelectedAssigneeList())
            
            assignmentViewModel.createAssignmentForProject(projectId, name:assignmentNameTextFiled.text! ,startDate: startDatecommitmentDatePicker.date, targetDate: targetDatecommitmentDatePicker.date, description: assignmentDescriptionTextView.text, assignees:assignmentViewModel.getSelectedAssigneeList()){result,err in
                if result{
                  dispatch_async(dispatch_get_main_queue(), {
                        
                        self.navigationController?.popViewControllerAnimated(true)
                  })
                    
                }
                else {
                    PLSharedManager.showAlertIn(self, error: err!, title: "Error Occured", message: err.debugDescription)
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
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0
        {
        return assignmentViewModel.numbersOfRows()
        }
        return 0
    }
    
    
      func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! PLAssigneeTableViewCell
        cell.nameLabel.text = assignmentViewModel.memberName(indexPath.row)
        cell.mailIdField.text = assignmentViewModel.memberEmail(indexPath.row)
        cell.disclosureButton.tag = indexPath.row
        assignmentViewModel.contributorImageRowAtIndexPath(indexPath.row, completion: { (avatar) in
            
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

        if PLSharedManager.manager.projectCreatedByUserId == QBSession.currentSession().currentUser?.ID
        {
            cell.disclosureButton.hidden = false
            cell.disclosureButton.addTarget(self, action: #selector(PLProjectAssignmentViewController.loadProfileController(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        }
        else
        {
            if assignmentViewModel.isLoggedInUserPartOfAssignment()
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

        if assignmentViewModel.selectedAssignment == nil{
            cell.statusField.text = ""
            cell.statusField.hidden = true
        
        }else{
            cell.statusField.hidden = false
            if assignmentViewModel.selectedAssignmentStatus() == 0{
                
                let assigneeStatus = assignmentViewModel.assigneeStatus(indexPath.row)
                cell.statusField.progressColor = UIColor.blueColor()
               cell.statusField.progress = assignmentViewModel.percentageCompletedByAssignee(indexPath.row)
               cell.statusField.text = "\(assignmentViewModel.percentageCompletedByAssignee(indexPath.row) * 100)%"
                if assigneeStatus == "1"{
                  cell.statusField.text = "Submitted"
                  cell.statusField.textColor = UIColor.redColor()
                  cell.statusField.trackWidth = 0
                  cell.statusField.progressWidth = 0
                }
                
                loggedInUserStatus = assignmentViewModel.assigneeStatus(0)
                if loggedInUserStatus == "1"{
                    headerColor = UIColor(colorLiteralRed: 89/255, green: 181/255, blue: 50/255, alpha: 0.5)
                    assignmentStatus.setTitle("Submitted", forState: .Normal)
                    assignmentStatus.enabled = false
                    completeStatusLabel.hidden = true
                    assignmentStatusSlider.hidden = true
                }
            }
            else{
                
                cell.statusField.text = "Closed"
                cell.statusField.textColor = UIColor.redColor()
                cell.statusField.trackWidth = 0
                cell.statusField.progressWidth = 0
                completeStatusLabel.hidden = true
                assignmentStatusSlider.hidden = true
            }
            
        }
   
        
        return cell
     
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 70.0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0
        {
        if assignmentViewModel.selectedAssignment != nil
        {
            return "ASSIGNED TO"
        }
        
        return "SELECT ONE OR MORE ASSIGNEES"
        }
        return nil
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        headerView  = UIView(frame:CGRectMake(0,0,self.view.frame.size.width,20))
        headerView.layer.cornerRadius = 15
        headerView.clipsToBounds = true
        headerView.backgroundColor = UIColor.clearColor()

        if section == 1
        {
            
            if assignmentViewModel.selectedAssignment != nil{
               
               let userId = QBSession.currentSession().currentUser?.ID
                if userId! == PLSharedManager.manager.projectCreatedByUserId{
                    
                    self.addButtonForTableViewFooterOnView(headerView, title: "Close", tag: -1)
                    
                }else{
                    
                    if assignmentViewModel.isLoggedInUserPartOfAssignment()
                    {
                        if loggedInUserStatus == "0"{
                            headerView.backgroundColor = UIColor(colorLiteralRed: 89/255, green: 181/255, blue: 50/255, alpha: 1)
                            self.addButtonForTableViewFooterOnView(headerView, title: "Completed ?", tag: 1)
                            assignmentStatus.enabled = true
                        }else if loggedInUserStatus == "1"{
                            headerView.backgroundColor = UIColor(colorLiteralRed: 89/255, green: 181/255, blue: 50/255, alpha: 0.5)
                            self.addButtonForTableViewFooterOnView(headerView, title: "Submitted", tag: 1)
                            assignmentStatus.enabled = false
                        }
                        
                    }
                    else{
                        return nil
                    }
                }

        }
            
            if assignmentViewModel.isUserCreatorOfAssignment(){
              headerView.backgroundColor = UIColor(colorLiteralRed: 89/255, green: 181/255, blue: 50/255, alpha: 1)
              assignmentStatus.enabled = true
            }
            
            if let _ = assignmentViewModel.selectedAssignment{
            if assignmentViewModel.selectedAssignmentStatus() != 0{
                
             if assignmentViewModel.selectedAssignmentStatus() != 0{
                
                    headerView.backgroundColor = UIColor(colorLiteralRed: 235/255, green: 35/255, blue: 38/255, alpha: 0.5)
                    assignmentStatus.setTitle("Closed", forState: UIControlState.Normal)
                    assignmentStatus.enabled = false
            }else{
                    assignmentStatus.setTitle("Close", forState: UIControlState.Normal)
                    assignmentStatus.enabled = true
                }
            }
        }
       return headerView
        }else if section == 2{
            if assignmentViewModel.numberOfAssigneesCompletedAssignment() > 0 && assignmentViewModel.isUserCreatorOfAssignment(){
                headerView.backgroundColor = UIColor(colorLiteralRed: 89/255, green: 181/255, blue: 50/255, alpha: 1)
                self.addButtonForTableViewFooterOnView(headerView, title: "Reopen", tag: 2)
            }
           
            return headerView
        }
        return nil
  }
    
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if assignmentViewModel.selectedAssignment == nil
        {
            
            if selectedIndexes.containsObject(indexPath){
                
                selectedIndexes.removeObject(indexPath)
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
                assignmentViewModel.removeAssignee(indexPath.row)
            }else{
                selectedIndexes.addObject(indexPath)
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
                assignmentViewModel.addAssignee(indexPath.row)
            }
        }
     }
    
    func addButtonForTableViewFooterOnView(addOnView:UIView,title:String,tag:Int)
    {
         assignmentStatus = UIButton(type:.Custom)
        assignmentStatus.tag = tag
        assignmentStatus.setTitle(title, forState: UIControlState.Normal)
        assignmentStatus.titleLabel?.font = UIFont(name:"Avenir Next Demi Bold ", size: 24)
        assignmentStatus.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        assignmentStatus.addTarget(self, action:#selector(PLProjectAssignmentViewController.performButtonActionOfFooterView), forControlEvents: UIControlEvents.TouchUpInside)
        assignmentStatus.frame = CGRectMake(0, 0, self.view.frame.size.width, 40)
        assignmentStatus.contentHorizontalAlignment = .Center
        assignmentStatus.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        addOnView.addSubview(assignmentStatus)
    }

    func performButtonActionOfFooterView(sender:UIButton)
    {
        print(sender.tag)
        if sender.tag == 1{
            assignmentViewModel.updateAssigmentStatusOfLoggedInUser(1){res,err in
                if res{
                    self.assignmentStatus.setTitle("Submitted", forState:.Normal)
                    self.assignmentStatus.enabled = false
                    self.loggedInUserStatus = "1"
                    self.assigneeListTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:0, inSection:0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                else
                {
                    PLSharedManager.showAlertIn(self, error: err!, title: "Error Occured while updating the assignment", message: err.debugDescription)
                }
            }
        }
        else if sender.tag == -1{
            
            print("Close issue")
            
            /*assignmentViewModel.updateAssigmentStatusOfLoggedInUser(-1){ [weak self] res,err in
                if res{
                    self!.assigneeListTableView.reloadData()
                }else{
                    //self!.showAlertWithMessage("Cannot Close", message: "Assignment is still in progress by some assignees")
                    PLSharedManager.showAlertIn(self!, error: err!, title: "Cannot Close - Assignment is still in progress by some assignees", message: err.debugDescription)
                }
            }*/
            
            if assignmentViewModel.numberOfAssigneesCompletedAssignment() == 1{
                showAlertWithMessage("Are you sure to close?", message:"you can also reopen anssignment once after you close if needed", cancelNeeded: true)
            }else{
                
                showPopOver(sender,type: "Close to members")//show popover
            }
            

        }else{
            
            if assignmentViewModel.numberOfAssigneesCompletedAssignment() == 1{
            showAlertWithMessage("Are you sure to reopen?", message:"Reopening issue will notify users to rework on the assignment", cancelNeeded: true)
            }else{
                
                showPopOver(sender,type: "Reopen to membrs")//show popover
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearFields()
    {
       self.title = ""
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
        profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLUserProfileInfoTableViewController") as? PLUserProfileInfoTableViewController
        profileViewController.disablingBtn = false
        refreshFlag = false
        profileViewController.userProfileModel = PLUserProfileInfoViewModel()
        let userId = assignmentViewModel.getSelectedAssigneeUserId(sender.tag)
        profileViewController.fetchingUserDetails(userId)
        profileViewController.userName = assignmentViewModel.memberName(sender.tag)
        profileViewController.delegate = self
        if assignmentViewModel.selectedAssignment != nil
        {
            profileViewController.selectedAssignment = assignmentViewModel.selectedAssignment
        }
        self.navigationController!.pushViewController(profileViewController!, animated: true)
    }
    
    func selectedAssignment(assignment: PLAssignment) {
       assignmentViewModel.selectedAssignment = assignment
    }
    
    func showAlertWithMessage(title:String,message:String,cancelNeeded:Bool)
    {
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                if cancelNeeded{
                    
                    print("Reopen Issue Alert")
                }
              
            })
            if cancelNeeded{
                
                let cancelAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    
                })
             alertController.addAction(cancelAction)
            }
            alertController.addAction(action)
            
            self.presentViewController(alertController, animated:true, completion:nil)
            
        } else {
            let alert = UIAlertView(title: title, message: message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok") as UIAlertView
            alert.show()
            
            // Fallback on earlier versions
        }
        
        
    }
    
    @IBAction func didChangeAssignmentProgress(sender: UISlider) {
        
      let completed =  Int(sender.value)
       completeStatusLabel.text = "\(completed) % Done"
       isSliderValueChanged = true
       let cell  = assigneeListTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! PLAssigneeTableViewCell
        let value = Int(sender.value)
        cell.statusField.progress = CGFloat(sender.value/100)
        cell.statusField.text = "\(value)%"
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !assignmentStatusSlider.hidden{
            if isSliderValueChanged{
            assignmentViewModel.updateAssignmentPercentage(Int(assignmentStatusSlider.value))
            }
        }
        
        //assignmentViewModel.selectedAssignment = nil
        //selectedIndexes = []
    }
    
    
    func showPopOver(sender:UIButton,type:String) {
        
        if diplayMembersPopover == nil
        {
            diplayMembersPopover = self.storyboard?.instantiateViewControllerWithIdentifier("PLDisplayMembersPopover") as? PLDisplayMembersPopover
            setUpNavigationBarForPopover()
        }
       
      
       diplayMembersPopover.title = type
       
        
        diplayMembersPopover.teamMemberModelView = PLTeamMemberModelView(searchMembers:assignmentViewModel.membersWithClosedAssignmentStatus());
        plPopOverController!.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        plPopOverController?.popoverContentSize = CGSizeMake(300, 200)
        plPopOverController!.wantsDefaultContentAppearance = true;
        plPopOverController?.presentPopoverFromRect(sender.bounds, inView: sender, permittedArrowDirections: WYPopoverArrowDirection.Any, animated: true)
    }
    
    func setUpNavigationBarForPopover()
    {
       
        diplayMembersPopover.modalInPopover = false
        diplayMembersPopover.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target:self, action:#selector(PLProjectAssignmentViewController.close))
        let navigationController = UINavigationController(rootViewController: diplayMembersPopover)
        plPopOverController = WYPopoverController(contentViewController:navigationController)
    }
    
    func close(){
        
       print(diplayMembersPopover.selectedRows)
        plPopOverController?.dismissPopoverAnimated(true)
       
    }

    
}
