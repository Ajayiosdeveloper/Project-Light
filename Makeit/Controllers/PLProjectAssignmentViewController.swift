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
    var projectDetailController = PLProjectDetailTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let teamMembers = PLTeamMember(name: "", id: 0)
        teamMembers.fullName = (QBSession.currentSession().currentUser?.fullName)!
        teamMembers.memberEmail = (QBSession.currentSession().currentUser?.email)!
        teamMembers.projectId = ""
        teamMembers.avatar = ""
        teamMembers.memberId = ""
        print("Team \(teamMembers)")
     //   projectDetailController.projectDetailViewModel! = PLProjectDetailViewModel(members: <#T##[PLTeamMember]#>)
        print(assignementViewModel.assigneeList)
        self.assigneeListTableView.registerNib(UINib(nibName:"PLTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier: "Cell")
        addDoneBarButtonItem()
        startDatecommitmentDatePicker = UIDatePicker()
        startDatecommitmentDatePicker.datePickerMode = .Date
        self.assignmentStartDateTextField.inputView = startDatecommitmentDatePicker
        startDateDoneButtonToDatePicker()
        
        targetDatecommitmentDatePicker = UIDatePicker()
        targetDatecommitmentDatePicker.datePickerMode = .Date
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
        assignmentStartDateTextField.text = NSDateFormatter.localizedStringFromDate(startDatecommitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
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
        assignmenttargetDateTextField.text = NSDateFormatter.localizedStringFromDate(targetDatecommitmentDatePicker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        assignmentDescriptionTextView.becomeFirstResponder()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return assignementViewModel.numbersOfRows()
        
    }
    
      func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! PLTableViewCell
        cell.memberName.text = assignementViewModel.titleOfRowAtIndexPath(indexPath.row)
        cell.memberDetail.text = assignementViewModel.emailOfRowAtIndexPath(indexPath.row)
        print(projectDetailController)
        
//        if projectDetailController.projectDetailViewModel.isUserAssignedToAssignment(indexPath.row)
//        {
//            cell.disclosureIndicatorBtn.hidden = true
//        }
//        else
//        {
//        cell.disclosureIndicatorBtn.hidden = false
//        cell.disclosureIndicatorBtn.addTarget(self, action: #selector(PLProjectAssignmentViewController.loadProfileController), forControlEvents:UIControlEvents.TouchUpInside)
//        }
        assignementViewModel.contributorImageRowAtIndexPath(indexPath.row, completion: { (avatar) in
            
            if let _ = avatar{
                
                cell.teamMemberProfile.image = avatar!
                cell.teamMemberProfile.layer.masksToBounds = true
            }else{
                
                cell.teamMemberProfile.image = UIImage(named:"UserImage.png")
            }
        })
        
        if selectedIndexes.containsObject(indexPath){
            cell.accessoryType = .Checkmark
        }else{
            cell.accessoryType = .None
        }
   
        return cell
     
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if assignementViewModel.selectedAssignment != nil
        {
            return "ASSIGNED TO"
        }
        
        return "SELECT ONE OR MORE ASSIGNEES"
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if assignementViewModel.selectedAssignment != nil{
           
            let footerView:UIView! = UIView(frame:CGRectMake(0,0,self.view.frame.size.width-0,40))
            footerView.backgroundColor = UIColor(colorLiteralRed: 89/255, green: 181/255, blue: 50/255, alpha: 1)
            footerView.layer.cornerRadius = 15
            footerView.clipsToBounds = true
            
            let userId = QBSession.currentSession().currentUser?.ID
            if userId! == PLSharedManager.manager.projectCreatedByUserId{
                
                self.addButtonForTableViewFooterOnView(footerView, title: "Close", tag: 1)
                
            }else{
                
                self.addButtonForTableViewFooterOnView(footerView, title: "Completed ?", tag: 1)
            }
            
            
            return footerView
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
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
        addMemberButton.contentEdgeInsets = UIEdgeInsetsMake(15, 0, 0, 0)
        addOnView.addSubview(addMemberButton)
    }

    func performButtonActionOfFooterView(){
        
        
        print("PRAISE THE LORD")
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
    
    func loadProfileController()
    {
       let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLUserProfileInfoTableViewController") as? PLUserProfileInfoTableViewController
       let nav = UINavigationController(rootViewController: profileViewController!)
       self.presentViewController(nav, animated: true, completion: nil)
       profileViewController?.addBackBarButtonItem()
       self.disableImproveProfile()
        
    }
    
    
    func disableImproveProfile()-> Bool
    {
        return false
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
