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

class PLProjectDetailTableViewController: UITableViewController,EKEventEditViewDelegate {
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
    
    @IBOutlet var projectDetailsTableView: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.projectDetailsTableView.registerNib(UINib(nibName:"PLTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier: "Cell")
        self.projectDetailsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:"DefaultCell")
        commitmentViewModel.isAccessGranted(){res in
            if res{
                PLSharedManager.manager.isCalendarAccess = true
            }else{
                PLSharedManager.manager.isCalendarAccess = false
            }
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchDataFromRemote()
        
        self.navigationItem.title = projectName
        projectDetailsTableView.reloadData()
        taskPriority = ""
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
  
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
            return 4
      
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var total = 0
        if section == 0 {
           total = projectDetailViewModel.numbersOfContributorsRows()
        }
        else if section == 1{
           
                total = projectDetailViewModel.numberOfCommitmentRows()
        }
        else if section == 2
        {
            total = projectDetailViewModel.numberOfAssignmentRows()
        }
        else if section == 3
        {
            total = 3
        }
        return total
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
        if indexPath.section == 0{
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PLTableViewCell
        cell.memberName.text = projectDetailViewModel.contributorTitleForRowAtIndexPath(indexPath.row)
        cell.memberDetail.text = projectDetailViewModel.contributorEmailForRowAtIndexPath(indexPath.row)
        cell.accessoryType = .DisclosureIndicator
        projectDetailViewModel.contributorImageRowAtIndexPath(indexPath.row, completion: { (avatar) in
            
            if let _ = avatar{
                
                cell.teamMemberProfile.image = avatar!
            }else{
                
                cell.teamMemberProfile.image = UIImage(named:"UserImage.png")
            }
            
        })
        
            
        return cell
        }
        else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)  as UITableViewCell
            cell.textLabel?.text = projectDetailViewModel.commitmentTitleForRowAtIndexPath(indexPath.row)
            cell.detailTextLabel?.text = projectDetailViewModel.commitmentSubTitleForRowAtIndexPath(indexPath.row)
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.textColor = UIColor.blackColor()
            return cell
        }
        else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)  as UITableViewCell

            cell.textLabel?.text = projectDetailViewModel.assignmentTitleForRowAtIndexPath(indexPath.row)
            cell.detailTextLabel?.text = projectDetailViewModel.assignmentSubTitleForRowAtIndexPath(indexPath.row)
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.accessoryType = .DisclosureIndicator
            return cell
        }
        else if indexPath.section == 3{
            let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)  as UITableViewCell
            cell.textLabel?.text = projectDetailViewModel.communicationType(indexPath.row)
            cell.detailTextLabel?.text = ""
            cell.textLabel?.textColor = enableButtonColor
            return cell
        }
       
        return UITableViewCell()
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        
//    }
    
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
            self.addButtonForTableViewFooterOnView(footerView, title:"Add Assigniment", tag:section)
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
        
        return headerTitle
        
    }
    
   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0
        {
            return 55.0
        }
         return 44.0
    }
    
    override   func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 40.0
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
        assignmentViewController.assignementViewModel = PLProjectAssignmentViewModel(assignees: projectDetailViewModel.getProjectContributorsList())
        self.navigationController?.pushViewController(assignmentViewController, animated: true)
    
    }
    
    func showEventEditViewController(event:EKEvent?)
    {
        let editViewController = EKEventEditViewController()
        editViewController.eventStore = EKEventStore()
        editViewController.editViewDelegate = self
        if let _ = event{
            
            let ev = EKEvent(eventStore:EKEventStore())
            ev.title = event!.title
            ev.notes = event!.notes
            print("Coming")
            print(ev.title)
            editViewController.event = ev
        }
       //let array = editViewController.navigationBar.items;
        //let titleItem = array![0]
       // titleItem.title = projectName
        self.presentViewController(editViewController, animated: true, completion:nil)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0
        {
            let selectedMember = projectDetailViewModel.selectedContributor(indexPath.row)
            
            if teamMemberDetailViewController == nil{
                
                teamMemberDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLTeamMemberDetailsTableViewController") as! PLTeamMemberDetailsTableViewController
            }
            teamMemberDetailViewController.teamMemberDetailViewModel = PLTeamMemberDetailViewModel(withMemberName: selectedMember.fullName,userId: selectedMember.memberUserId,projectId: selectedMember.projectId)
            self.navigationController?.pushViewController(teamMemberDetailViewController, animated:true)
        
        }
        else if indexPath.section  == 1
        {
          let commitment = projectDetailViewModel.selectedCommitmentFor(indexPath.row)
            
        if PLSharedManager.manager.isCalendarAccess{
                
            print(commitment?.startDate)
            print(commitment?.targetDate)
            let startDate = getDateForCommitmentUsingString((commitment?.startDate)!)
            let endDate = getDateForCommitmentUsingString((commitment?.targetDate)!)
            
            fetchEvents(startDate, endDate:endDate, completed: { (events) in
                
                   let  event = events.lastObject as! EKEvent
                   self.showEventEditViewController(event)
                
                })
            
            //if commitment!.isCompleted == 0{
                
               //self.performSelector(#selector(PLProjectDetailTableViewController.showTaskCompletePopup), withObject:nil, afterDelay:5)
                //}
            }
        else{
                 
            showCommitmentViewController()
             commitmentViewController.commitmentViewModel.commitment = projectDetailViewModel.selectedCommitmentFor(indexPath.row)
            print(commitmentViewController.commitmentViewModel.commitment)
           
            }
        }
        else if indexPath.section == 2
        {
            showAssignmentViewController()
            assignmentViewController.assignementViewModel.selectedAssignment = projectDetailViewModel.selectedAssignment(indexPath.row)
        }
        
        else if indexPath.section == 3{
            
            if indexPath.row == 0 {presentTeamCommunicationViewController(0)}
            else if indexPath.row == 1 {presentTeamCommunicationViewController(1)}
            else {presentProjectTeamChatViewController()}
            
        }
        
    }
    
    func fetchDataFromRemote()  {
        
        projectDetailViewModel.assignments = []
        projectDetailViewModel.commitments = []
        projectDetailViewModel.getCommitmentsFromRemote(projectId){[weak self]result in
            
            if result{  self!.projectDetailViewModel.getAssignmentsFromRemote(self!.projectId){result in
                
                if result{
                    self?.projectDetailsTableView.reloadData()
                }
                }
            }
        }
    }
    
    func presentTeamCommunicationViewController(type:Int)
    {
        if teamCommunicationViewController == nil{
            
            teamCommunicationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("teamCommunicationViewController") as! PLTeamCommunicationViewController
        }
        teamCommunicationViewController.communicationType = type
        teamCommunicationViewController.communicationViewModel = PLTeamCommunicationViewModel(members: projectDetailViewModel.contributors)
        self.navigationController?.pushViewController(teamCommunicationViewController, animated: true)
    }
    
   func presentProjectTeamChatViewController()
   {
    
    if projectTeamChatViewController == nil{
        projectTeamChatViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLProjectTeamChatViewController") as! PLProjectTeamChatViewController
    }
    
     projectTeamChatViewController.projectTeamChatViewModel = PLProjectTeamChatViewModel(teamMembers: projectDetailViewModel.contributors)
    
    
     self.navigationController?.pushViewController(projectTeamChatViewController, animated: true)
   
    }
    

    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction){
        
        if action == EKEventEditViewAction.Canceled{
            
            self.dismissViewControllerAnimated(true, completion:nil)
            
            return
        }
        
        if action == EKEventEditViewAction.Saved{
            
            if taskPriority == ""{
                
                let pop:Popup = Popup(title: "Set Task Priority", subTitle: "Assigning priority will help categorising your tasks easily", textFieldPlaceholders: ["PRIORITY"], cancelTitle: nil, successTitle: "Add Task", cancelBlock: {
                    
                }) {
                    self.taskPriority = NSUserDefaults.standardUserDefaults().valueForKey("PRIORITY") as! String
                    
                    var subTitle = ""
                    if let _ = controller.event?.notes{
                        subTitle = (controller.event?.notes!)!
                    }
                    self.performDone((controller.event?.title)!, description: subTitle, startDate:(controller.event?.startDate)!, targetDate:(controller.event?.endDate)!){ res in
                        SVProgressHUD.dismiss()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                pop.backgroundBlurType = .Dark
                pop.showPopup()
                return
            }
        
        }
    }
    
    func performDone(title:String,description:String,startDate:NSDate,targetDate:NSDate,completion:(Bool)->Void)
    {
        SVProgressHUD.showWithStatus("Saving")
        do{
            
            try commitmentViewModel.commitmentValidations(title,startDate: startDate,targetDate:targetDate, description:description)
            
              commitmentViewModel.addCommitmentToCalendar(title, date:startDate,endDate: targetDate)
              commitmentViewModel.createCommitmentWith(title,startDate: startDate,targetDate:targetDate,description:description ,projectId: projectId){ result in
                
                if result{
                    
                    completion(true)
                    
                }else {print("Handle Error")}
            }
        }
        catch CommitValidation.NameEmpty{print("Empty Name")}
        catch CommitValidation.InvalidDate{print("Earlier date")}
        catch CommitValidation.DescriptionEmpty{print("Empty Description")}
        catch {}
    }

    func fetchEvents(startDate: NSDate,endDate: NSDate,completed: ( NSMutableArray) -> ())
    {
        let eventStore = EKEventStore()
        let calendar = eventStore.defaultCalendarForNewEvents
       
        let predicate = eventStore.predicateForEventsWithStartDate(startDate, endDate:endDate, calendars:[calendar])
        let events = NSMutableArray(array:eventStore.eventsMatchingPredicate(predicate))
        completed(events)
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

}