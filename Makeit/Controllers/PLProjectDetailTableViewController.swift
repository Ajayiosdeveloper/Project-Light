//
//  PLProjectDetailTableViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI
import Quickblox

protocol ProjectDetailsDelegate:class{
    func check(details:[String],detailViewModel:PLProjectDetailViewModel)
}

class PLProjectDetailTableViewController: UITableViewController,EKEventEditViewDelegate,UIAlertViewDelegate {
    weak var delegate:ProjectDetailsDelegate?
    var projectDetailViewModel:PLProjectDetailViewModel!
    var projectName:String!
    var projectId:String!
    var projectDescription:String!
    var projectCreatedBy:UInt!
    var addProjectViewController:PLAddProjectViewController!
    var commitmentViewController:PLProjectCommentViewController!
    var assignmentViewController:PLProjectAssignmentViewController!
    var teamMemberDetailViewController:PLTeamMemberDetailsTableViewController!
    var teamCommunicationViewController:PLTeamCommunicationViewController!
    var projectTeamChatViewController:PLProjectTeamChatViewController!
    var commitmentViewModel:PLProjectCommentViewModel = PLProjectCommentViewModel()
    var taskPriority:String = ""
    var fetchDataFlag:Bool = false
    var editCommitment : Bool = false
    var event : EKEvent?
    let editViewController = EKEventEditViewController()
    var indexPath : NSIndexPath?
    var fromNotification: Bool = false
    
    @IBOutlet var projectDetailsTableView: UITableView!
   
    override func viewDidLoad()
    {
        super.viewDidLoad()
        editViewController.eventStore = EKEventStore()
        self.projectDetailsTableView.registerNib(UINib(nibName:"PLTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier: "Cell")
        self.projectDetailsTableView.registerNib(UINib(nibName:"PLAssignmentTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier: "AssignmentCell")
        self.projectDetailsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:"DefaultCell")
        
          commitmentViewModel.isAccessGranted(){res in
            if res
            {
                PLSharedManager.manager.isCalendarAccess = true
            }else{
                PLSharedManager.manager.isCalendarAccess = false
            }
        }
       
        print("viewDidLoad")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        projectDetailsTableView.userInteractionEnabled = true
        if (fetchDataFlag == false)
        {
            fetchDataFromServer()
        }
        else
        {
            print("Dont Fetch")
        }
        self.navigationItem.title = projectName
        projectDetailsTableView.reloadData()
        PLDynamicEngine.expandCellsFromMiddleWith3D(self.projectDetailsTableView.visibleCells)
       
        taskPriority = ""
        if fromNotification
        {
            addHomeButton()
        }
        print("view appear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
  
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
    return projectDetailViewModel.numberOfSectionsInTableView()
      
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var total = 0
        if projectDetailViewModel.numberOfSectionsInTableView() == 4
        {
        
        if section == 0 {
           total = projectDetailViewModel.numbersOfContributors()
        }
        else if section == 1{
           
                total = projectDetailViewModel.numberOfCommitments()
        }
        else if section == 2
        {
            total = projectDetailViewModel.numberOfAssignments()
        }
        else if section == 3
        {
            total = 3
        }
        }
        else
        {
            if section == 0 {
                total = projectDetailViewModel.numbersOfContributors()
            }
            else if section == 1{
                
                 total = projectDetailViewModel.numberOfAssignments()
            }
            else if section == 2
            {
                total = 3
            }
     }
        return total
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PLTableViewCell
        cell.memberName.text = projectDetailViewModel.contributorTitle(indexPath.row)
        cell.memberDetail.text = projectDetailViewModel.contributorEmail(indexPath.row)
        cell.accessoryType = .DisclosureIndicator
        projectDetailViewModel.contributorImage(indexPath.row, completion: { (profilePicture,err) in
            
            if let _ = profilePicture{
                
                cell.teamMemberProfile.image = profilePicture!
                cell.teamMemberProfile.layer.masksToBounds = true
            }
            else{
                    cell.teamMemberProfile.image = UIImage(named:"UserImage.png")
                }
            })
        return cell
            
        }
      
        if projectDetailViewModel.numberOfSectionsInTableView() == 4{
            
            if indexPath.section == 1{
                let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "DefaultCell")
                self.configureCommitmentCell(cell, row: indexPath.row)
                return cell
            }
            if indexPath.section == 2{
                let cell = tableView.dequeueReusableCellWithIdentifier("AssignmentCell", forIndexPath: indexPath) as! PLAssignmentTableViewCell
                 self.configureAssignmentCell(cell, row: indexPath.row)
                return cell
                
            }
            if indexPath.section == 3{
                let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)  as UITableViewCell
                cell.textLabel?.text = projectDetailViewModel.communicationType(indexPath.row)
                cell.detailTextLabel?.text = ""
                cell.textLabel?.textColor = enableButtonColor
                cell.accessoryType = .DisclosureIndicator
                cell.accessoryView = nil

                return cell
            }
            
        }else{
            
            if indexPath.section == 1
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("AssignmentCell", forIndexPath: indexPath) as! PLAssignmentTableViewCell
                self.configureAssignmentCell(cell, row: indexPath.row)
                return cell
            }
            if indexPath.section == 2{
               
                let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)  as UITableViewCell
                cell.textLabel?.text = projectDetailViewModel.communicationType(indexPath.row)
                cell.detailTextLabel?.text = ""
                cell.textLabel?.textColor = enableButtonColor
                cell.accessoryType = .DisclosureIndicator
                cell.accessoryView = nil
                return cell
            }
        }
        return UITableViewCell()
    
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
         if projectDetailViewModel.numberOfSectionsInTableView() == 4{
            
        if indexPath.section == 1 || indexPath.section == 2
        {
            return UITableViewCellEditingStyle.Delete
        }
        return UITableViewCellEditingStyle.None
        }
        else
         {
            if indexPath.section == 1
            {
                return UITableViewCellEditingStyle.None
            }

        }
        return UITableViewCellEditingStyle.None
    }
    
  
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.indexPath = indexPath
        if projectDetailViewModel.numberOfSectionsInTableView() == 4{
            
        if indexPath.section == 1
        {
            
            if self.projectDetailViewModel.commitmentCompletedStatus(indexPath.row) == 1
            {
                self.deleteCommitment(indexPath, title: "Do you want to delete commitment?")
                
            }
            else
            {
                self.deleteCommitment(indexPath, title: "Commitment is not completed yet. Do you want to delete it?")
            }
        }
        else if  indexPath.section == 2
        {
            let assignmentCreator =  projectDetailViewModel.assignments[indexPath.row]
            print(assignmentCreator.creatorId)
            print(QBSession.currentSession().currentUser?.ID)
            if assignmentCreator.creatorId == QBSession.currentSession().currentUser?.ID
            {
                if assignmentCreator.assignmentStatus == 1
                {
                  deleteAssignment(indexPath, title: "Do you want to delete assignment")
                }
                else
                {
                    deleteAssignment(indexPath, title: "Assignment is not completed yet. Do you want to delete it")

                }
            }
           /* else
            {
                SVProgressHUD.dismiss()
                let alertController = UIAlertController(title: nil, message: "You are not creator of this assignment. So you can't delete it", preferredStyle: .ActionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    
                }
                alertController.addAction(cancelAction)
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
          }*/
            
        }
        }
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if alertView.tag == 0
        {
            if buttonIndex == 0{
                self.projectDetailViewModel.commitments.removeAtIndex(self.indexPath!.row)
                self.projectDetailsTableView.deleteRowsAtIndexPaths([self.indexPath!], withRowAnimation: UITableViewRowAnimation.Bottom)
              
            }
        }
        else
        {
            if buttonIndex == 0{
                self.projectDetailViewModel.assignments.removeAtIndex(self.indexPath!.row)
                self.projectDetailsTableView.deleteRowsAtIndexPaths([self.indexPath!], withRowAnimation: UITableViewRowAnimation.Bottom)
               
            }
        }
    }

    
    func deleteAssignment(indexPath: NSIndexPath, title: String)
    {
      
        if #available(iOS 8.0, *) {
            let alertViewController = UIAlertController.init(title: title, message: nil, preferredStyle: .Alert)
            let okAction = UIAlertAction.init(title: "Ok", style: .Default) {[weak self] (action) -> Void in
                SVProgressHUD.showWithStatus("Deleting")
                let assignment = self!.projectDetailViewModel.assignments[indexPath.row]
                
                self!.projectDetailViewModel.deleteCommitment(assignment.assignmentId, Completion: { (res, err) in
                   
                    if let _ = err
                    {
                        SVProgressHUD.dismiss()
                        PLSharedManager.showAlertIn(self!, error: err!, title: "Error occured while deleting the assignment in a particulare row", message: err.debugDescription)
                    }
                    else
                    {
                        SVProgressHUD.dismiss()
                        self!.projectDetailViewModel.assignments.removeAtIndex(indexPath.row)
                        self!.projectDetailsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
                        self!.projectDetailsTableView.reloadData()
                    }
                })
          }
            
            let cancelAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
            alertViewController.addAction(okAction)
            alertViewController.addAction(cancelAction)
            
            self.presentViewController(alertViewController, animated: true, completion: nil)
        }
        else
        {
            let alertView = UIAlertView(title: "Selected assignment is not yet completed. Do you want to delete it?", message: "", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Ok", "Cancel")
            alertView.show()
            alertView.tag = 1
            // Fallback on earlier versions
        }
    }

    
    func deleteCommitment(indexPath: NSIndexPath, title: String)
    {
        func refresh(){
            
            self.projectDetailViewModel.commitments.removeAtIndex(indexPath.row)
       
            self.projectDetailsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)

            self.projectDetailsTableView.reloadData()
        }
        
        if #available(iOS 8.0, *) {
            let alertViewController = UIAlertController.init(title: title, message: nil, preferredStyle: .Alert)
            let okAction = UIAlertAction.init(title: "Ok", style: .Default) {[weak self] (action) -> Void in
                SVProgressHUD.showWithStatus("Deleting")
                let commitment = self!.projectDetailViewModel.commitments[indexPath.row]
               
                self!.projectDetailViewModel.deleteCommitment(commitment.commitmentId, Completion: { (res, err) in
                    print("deleting")
                    
                   
                    if let _ = err
                    {
                        SVProgressHUD.dismiss()
                        PLSharedManager.showAlertIn(self!, error: err!, title: "Error occured while deleting the commitment in a particulare row", message: err.debugDescription)
                    }
                    else
                    {
                        SVProgressHUD.dismiss()
                        self!.fetchEvents(commitment.calendarIdentifier, completion: {[weak self] (event) in
                            
                            if let _ = event{
                       
                                let store = self!.editViewController.eventStore
                                
                               try! store.removeEvent(event!, span: EKSpan.ThisEvent, commit: true)
                                
                                refresh()

                            }else{
                               
                                refresh()
                            }
                            
                            })
                        
                    }
                })

                
               
            }
            
            let cancelAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
            alertViewController.addAction(okAction)
            alertViewController.addAction(cancelAction)
            
            self.presentViewController(alertViewController, animated: true, completion: nil)
        }
        else
        {
            let alertView = UIAlertView(title: "Selected commitment is not yet completed. Do you want to delete it?", message: "", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Ok", "Cancel")
            alertView.show()
            alertView.tag = 0
            // Fallback on earlier versions
        }
        
  
        
   }
    
    
    func configureCommitmentCell(cell:UITableViewCell,row:Int){
        
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(17)
        cell.textLabel?.text = projectDetailViewModel.commitmentTitleForRowAtIndexPath(row)
        cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(17)
        cell.detailTextLabel?.text = projectDetailViewModel.commitmentSubTitleForRowAtIndexPath(row)
        cell.accessoryType = .DisclosureIndicator

    }
    
    func configureAssignmentCell(cell:PLAssignmentTableViewCell,row:Int){
        cell.assignmentTitle.text = projectDetailViewModel.assignmentTitleForRowAtIndexPath(row)
        cell.asssignmentSubtitle.text = projectDetailViewModel.assignmentSubTitleForRowAtIndexPath(row)
        cell.progressLabel.text = String(format:"%.2f", projectDetailViewModel.assignmentCompletedPercentage(row)) + "%"  //"\(projectDetailViewModel.assignmentCompletedPercentage(row))%"
        cell.progressLabel.trackWidth = 10
        cell.progressLabel.progressWidth = 10
        cell.progressLabel.roundedCornersWidth  = 10
       
        cell.progressLabel.progress = CGFloat(projectDetailViewModel.assignmentCompletedPercentage(row))
        if cell.progressLabel.progress == 0{
            cell.progressLabel.progressColor = UIColor.lightGrayColor()
        }else{
             cell.progressLabel.progressColor = UIColor.blueColor()
        }
        
        cell.accessoryType = .DisclosureIndicator
 }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var footerView:UIView! = UIView(frame:CGRectMake(0,0,self.view.frame.size.width,40))
        footerView.backgroundColor = UIColor.whiteColor()
        if section == 0
        {
            if projectCreatedBy == QBSession.currentSession().currentUser?.ID{
                
                 self.addButtonForTableViewFooterOnView(footerView, title:"Add Contributor", tag:section)
            }else{footerView = nil}
            
            
        }
        else if section == 1{
            if projectCreatedBy == QBSession.currentSession().currentUser?.ID{
            self.addButtonForTableViewFooterOnView(footerView, title:"Add Commitment", tag:section)
            }else{footerView = nil}
        }
        else if section == 2{
            if projectCreatedBy == QBSession.currentSession().currentUser?.ID{
            self.addButtonForTableViewFooterOnView(footerView, title:"Add Assignment", tag:section)
            }else{footerView = nil}
        }
        else if section == 3
        {
            footerView = nil
        }
        
       return footerView
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var headerTitle:String = ""
        
        if projectDetailViewModel.numberOfSectionsInTableView() == 4{
            
            if section == 0{
                headerTitle = "CONTRIBUTORS"
            }
            else if section == 1
            {
                headerTitle = "COMMITMENTS"
            }
            else if section == 2
            {
                headerTitle = "ASSIGNMENTS"
            }
            else if section == 3
            {
                headerTitle = "COMMUNICATE"
            }
 
        }else{
            if section == 0{
                headerTitle = "CONTRIBUTORS"
            }
            else if section == 1
            {
                headerTitle = "ASSIGNMENTS"
            }
            else if section == 2
            {
                headerTitle = "COMMUNICATE"
            }
       }
        return headerTitle
        
    }
    
   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    if indexPath.section == 0{
        return 55
    }
        return 65
    }
    
    override   func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 40
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 40
    }
    
    func addButtonForTableViewFooterOnView(addOnView:UIView,title:String,tag:Int)
    {
        let addMemberButton = UIButton(type:.Custom)
        addMemberButton.tag = tag
        addMemberButton.setTitle(title, forState: UIControlState.Normal)
        addMemberButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        addMemberButton.setTitleColor(enableButtonColor, forState: UIControlState.Normal)
        addMemberButton.addTarget(self, action:#selector(PLProjectDetailTableViewController.addNewContributor), forControlEvents: UIControlEvents.TouchUpInside)
        addMemberButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 40)
        addMemberButton.contentHorizontalAlignment = .Left
        addMemberButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)
        addOnView.addSubview(addMemberButton)
    }
    
    func addNewContributor(sender:UIButton) {
        
        if sender.tag == 0{
            
           if addProjectViewController == nil
           {
             addProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLAddProjectViewController") as! PLAddProjectViewController
            }
           PLSharedManager.manager.existingContributorsList = projectDetailViewModel.contributors
           self.delegate = addProjectViewController
           self.navigationController?.pushViewController(addProjectViewController, animated:true)
           self.delegate?.check([projectId,projectName,projectDescription],detailViewModel: self.projectDetailViewModel)
 
        }
        if sender.tag == 1
        {
            if PLSharedManager.manager.isCalendarAccess{
                
               showEventEditViewController(nil)
               
                
            }else{
                
                showCommitmentViewController()
            }
            
        }
        else if sender.tag == 2
        {
            showAssignmentViewController()
        }
    }
    
    func  showCommitmentViewController() {
        
        if commitmentViewController == nil{
        
            commitmentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLProjectCommentViewController") as! PLProjectCommentViewController
            }
        commitmentViewController.projectId = projectId
       
    
        self.navigationController?.pushViewController(commitmentViewController, animated: true)
    }
 
    func  showAssignmentViewController() {
        
        if assignmentViewController == nil{
            
            assignmentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLProjectAssignmentViewController") as! PLProjectAssignmentViewController
        }
        assignmentViewController.projectId = projectId
        assignmentViewController.refreshFlag = true
        assignmentViewController.assignmentViewModel = PLProjectAssignmentViewModel(assignees: projectDetailViewModel.getProjectContributorsList())
        self.navigationController?.pushViewController(assignmentViewController, animated: true)
    
    }
    
    func showEventEditViewController(event:EKEvent?)
    {
        editViewController.editViewDelegate = self
        if let _ = event{
            print("Event is there")
           editViewController.event = event
        }else{
            print("No Event")
        }
        self.presentViewController(editViewController, animated: true, completion:nil)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        fetchDataFlag = true
        
        if projectDetailViewModel.numberOfSectionsInTableView() == 4
        {
            if indexPath.section == 0
            {
                let selectedMember = projectDetailViewModel.selectedContributor(indexPath.row)
                
                if teamMemberDetailViewController == nil{
                    
                    teamMemberDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLTeamMemberDetailsTableViewController") as! PLTeamMemberDetailsTableViewController
                }
                teamMemberDetailViewController.teamMemberDetailViewModel = PLTeamMemberDetailViewModel(withMemberName: selectedMember.fullName,userId: selectedMember.memberUserId,projectId: selectedMember.projectId)
                teamMemberDetailViewController.selectedMember = projectDetailViewModel.selectedContributor(indexPath.row)
                teamMemberDetailViewController.projectDetailViewModel = projectDetailViewModel
                teamMemberDetailViewController.projectDetailViewModel.contributors = projectDetailViewModel.contributors
                self.navigationController?.pushViewController(teamMemberDetailViewController, animated:true)
                
            }
            else if indexPath.section  == 1
            {
                let commitment = projectDetailViewModel.selectedCommitment(indexPath.row)
                
                if PLSharedManager.manager.isCalendarAccess{
                    commitmentViewModel.commitment = projectDetailViewModel.selectedCommitment(indexPath.row)
                   
                    if commitment?.calendarIdentifier == "NULL"{
                        self.editCommitment = false
                        showCommitmentViewController()
                        commitmentViewController.commitmentViewModel.commitment = commitment
                    
                    }else{
                            fetchEvents((commitment?.calendarIdentifier)!, completion: {[weak self] (event) in
                            
                                print("Fetch events")
                                
                                self!.editCommitment = true
                                if let _ = event{
                                    
                                    var events = EKEvent(eventStore: self!.editViewController.eventStore)
                                    events = event!
                                    self!.showEventEditViewController(events)
                                }else{
                                    print("Else part fetch")
                                    self!.showCommitmentViewController()
                                    self!.commitmentViewController.commitmentViewModel.commitment = self!.projectDetailViewModel.selectedCommitment(indexPath.row)
                                }
                            })
                    }
                }
                else{
                    
                    showCommitmentViewController()
                    commitmentViewController.commitmentViewModel.commitment = projectDetailViewModel.selectedCommitment(indexPath.row)
                    print(commitmentViewController.commitmentViewModel.commitment)
                    
                }
            }
            else if indexPath.section == 2
            {
                showAssignmentViewController()
                assignmentViewController.assignmentViewModel.selectedAssignment = projectDetailViewModel.selectedAssignment(indexPath.row)
            }
                
            else if indexPath.section == 3{
                
                if indexPath.row == 0 {presentTeamCommunicationViewController(0)}
                else if indexPath.row == 1 {presentTeamCommunicationViewController(1)}
                else {presentProjectTeamChatViewController()}
                
            }

        }
        
        else{
            //else part
            
            if indexPath.section == 0
            {
                let selectedMember = projectDetailViewModel.selectedContributor(indexPath.row)
                
                if teamMemberDetailViewController == nil{
                    
                    teamMemberDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLTeamMemberDetailsTableViewController") as! PLTeamMemberDetailsTableViewController
                    
                }
                teamMemberDetailViewController.teamMemberDetailViewModel = PLTeamMemberDetailViewModel(withMemberName: selectedMember.fullName,userId: selectedMember.memberUserId,projectId: selectedMember.projectId)
                teamMemberDetailViewController.projectDetailViewModel = projectDetailViewModel
                teamMemberDetailViewController.projectDetailViewModel.contributors = projectDetailViewModel.contributors
                self.navigationController?.pushViewController(teamMemberDetailViewController, animated:true)
                
            }
            else if indexPath.section == 1
            {
                showAssignmentViewController()
                assignmentViewController.assignmentViewModel.selectedAssignment = projectDetailViewModel.selectedAssignment(indexPath.row)
            }
                
            else if indexPath.section == 2{
                
                if indexPath.row == 0 {presentTeamCommunicationViewController(0)}
                else if indexPath.row == 1 {presentTeamCommunicationViewController(1)}
                else {presentProjectTeamChatViewController()}
                
            }

            
            //end of else part
        }
        
         projectDetailsTableView.userInteractionEnabled = false
    }
    
    func fetchDataFromServer()  {
        
        projectDetailViewModel.assignments = []
        projectDetailViewModel.commitments = []
        projectDetailViewModel.getCommitmentsFromServer(projectId){[weak self]result,err in
            
            if result{
                self!.projectDetailsTableView.reloadData()
            }
            
        }
        
        self.projectDetailViewModel.getAssignmentsFromServer(self.projectId){[weak self]result,err in
            
            if result{
                self!.projectDetailsTableView.reloadData()
            }
        }
    }
    
    func presentTeamCommunicationViewController(type:Int)
    {
        if teamCommunicationViewController == nil{
            
            teamCommunicationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("teamCommunicationViewController") as! PLTeamCommunicationViewController
        }
        teamCommunicationViewController.communicationType = type
        teamCommunicationViewController.projectDetailViewModel = projectDetailViewModel
        teamCommunicationViewController.projectDetailViewModel.contributors = projectDetailViewModel.contributors
        teamCommunicationViewController.communicationViewModel = PLTeamCommunicationViewModel(members: projectDetailViewModel.contributors)
    
        self.navigationController?.pushViewController(teamCommunicationViewController, animated: true)
    }
    
   func presentProjectTeamChatViewController()
   {
    
    if projectTeamChatViewController == nil{
        projectTeamChatViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLProjectTeamChatViewController") as! PLProjectTeamChatViewController
         print("Contributors")
        projectTeamChatViewController.enbleAndDisable = true
        projectTeamChatViewController.projectTeamChatViewModel = PLProjectTeamChatViewModel(teamMembers: projectDetailViewModel.contributors)
        print("Contributors")
        print(projectDetailViewModel.contributors)
        SVProgressHUD.showWithStatus("Loading")
        
        projectTeamChatViewController.projectTeamChatViewModel.fetchChatGroups {[weak self] (res,err) in
            
            if res
            {
                SVProgressHUD.dismiss()
                self!.navigationController?.pushViewController(self!.projectTeamChatViewController, animated: true)
            }
            else
            {
                SVProgressHUD.dismiss()
            }
        }
    }
    else
    {
        self.navigationController?.pushViewController(projectTeamChatViewController, animated: true)

    }
    
    }
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction){
        
        if action == EKEventEditViewAction.Canceled{
            SVProgressHUD.dismiss()
            self.dismissViewControllerAnimated(true, completion:nil)
            
            return
        }
       if action == EKEventEditViewAction.Saved{
        event = editViewController.event
        if editCommitment
        {
            commitmentViewModel.updateCommitmentWith((controller.event?.title)!, startDate:(controller.event?.startDate)! , targetDate: (controller.event?.endDate)!, description:(controller.event?.notes
                )!, projectId: projectId, completion: { (res) in
            
                    if res{
                
                SVProgressHUD.dismiss()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        
          })
        
        }
        else{
        
            if taskPriority == ""{
                
                let pop:Popup = Popup(title: "Set Task Priority", subTitle: "Assigning priority will help categorising your tasks easily", textFieldPlaceholders: ["PRIORITY"], cancelTitle: nil, successTitle: "Add Task", cancelBlock: {
                    
                }) {
                    self.taskPriority = NSUserDefaults.standardUserDefaults().valueForKey("PRIORITY") as! String
                    
                    self.performDone((controller.event?.title)!, description: (controller.event?.notes!)!, startDate:(controller.event?.startDate)!, targetDate:(controller.event?.endDate)!){ res in
                        
                        if res
                        {
                            SVProgressHUD.dismiss()
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else
                        {
                            SVProgressHUD.dismiss()
                        }
                        
                    }
                }
                pop.backgroundBlurType = .Dark
                pop.showPopup()
                return
            }

        }
            
        
        }
    }
    
    func performDone(title:String,description:String,startDate:NSDate,targetDate:NSDate,completion:(Bool)->Void)
    {
        SVProgressHUD.showWithStatus("Saving")
        do{
            
            try commitmentViewModel.commitmentValidations(title,startDate: startDate,targetDate:targetDate, description:description)
            
            commitmentViewModel.addCommitmentToCalendar(title, date:startDate,endDate: targetDate, description: description, event:event!){[weak self] identifier in
                self!.commitmentViewModel.createCommitmentWith(title,startDate: startDate,targetDate:targetDate,description:description ,projectId: self!.projectId,identifier: identifier){ result,err in
                    
                    if result{
                        
                        completion(true)
                        
                    }else {
                        PLSharedManager.showAlertIn(self!, error: err!, title: "Create Commitment Failed", message: "Error occrued while creating the Commitment")
                        print("Handle Error")}
                }
            }
            
        }
        catch CommitValidation.NameEmpty{print("Empty Name")}
        catch CommitValidation.InvalidDate{print("Earlier date")}
        catch CommitValidation.DescriptionEmpty{print("Empty Description")}
        catch {}
    }

    func fetchEvents(identifier:String,completion: (EKEvent?) -> ())
    {
        let event = editViewController.eventStore.eventWithIdentifier(identifier)
        if let _ = event{
            completion(event!)
        }else{
            
            completion(nil)
        }
       
    }

    func showTaskCompletePopup() {
        
        let popUp = Popup(title: "Update Task Status", subTitle:"Provide current status of the Task for better managing your tasks and to know project status accurately ", cancelTitle:"Not Yet!", successTitle: "Finished", cancelBlock: {
               print("Not yet pressed")
            }) { 
                print("Finished pressed")
        }
        popUp.backgroundBlurType = .Dark
        popUp.showPopup()
        
    }
    
   func getDateForCommitmentUsingString(dateString:String)->NSDate{
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
    print(dateFormatter.dateFromString(dateString))
    return dateFormatter.dateFromString(dateString)!
    
}

    func addHomeButton()
    {
        let leftHomeBtn = UIBarButtonItem(title: "Home", style:.Plain, target: self, action: #selector(PLProjectDetailTableViewController.performHomeButtonAction))
        self.navigationItem.leftBarButtonItem = leftHomeBtn
    }
    
    func performHomeButtonAction()
    {
        print("Home Btn")
       
        presentProjectsViewController()
    }
    
    func presentProjectsViewController(){
        
        let sideBarRootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLSidebarRootViewController") as! PLSidebarRootViewController
        self.presentViewController(sideBarRootViewController, animated: true, completion:nil)
    }
}