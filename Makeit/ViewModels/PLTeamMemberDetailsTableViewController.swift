//
//  PLTeamMemberDetailsTableViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 23/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLTeamMemberDetailsTableViewController: UITableViewController {
    
    @IBOutlet var memberDetailsTableview: UITableView!
    
    var teamMemberDetailViewModel:PLTeamMemberDetailViewModel!
    var projectDetailViewModel:PLProjectDetailViewModel!
    var projectTeamChatViewController:PLProjectTeamChatViewController!
    var teamCommunicationViewController:PLTeamCommunicationViewController!
    var selectedMember : PLTeamMember!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.memberDetailsTableview.registerNib(UINib(nibName: "PLTeamMemberDetailsTableViewCell",bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Cells")
        self.memberDetailsTableview.registerClass(UITableViewCell.self, forCellReuseIdentifier:"DefaultCell")
    }

    override func viewWillAppear(animated: Bool) {
      super.viewWillAppear(animated)
        memberDetailsTableview.userInteractionEnabled = true
      self.title = teamMemberDetailViewModel.getTeamMemberName()
        teamMemberDetailViewModel.getAssignmentsOfUserForProject(){[weak self] res,err in
            
            if res{
                self!.memberDetailsTableview.reloadData()
            }
            else
            {
                PLSharedManager.showAlertIn(self!, error: err!, title: "Error occured while fetching user from the server", message: err.debugDescription)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return teamMemberDetailViewModel.getNumberOfAssignmentRows()
        }
        else if section == 1{
            return teamMemberDetailViewModel.getNumberOfCommunicateRows()
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        PLDynamicEngine.animateCell(cell, withTransform: PLDynamicEngine.TransformCurl, andDuration:1)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cells", forIndexPath: indexPath) as! PLTeamMemberDetailsTableViewCell
        cell.assignmentTitle.text = teamMemberDetailViewModel.getAssignmentTitle(indexPath.row)
        cell.assignmentDetail.hidden = false
        cell.statusField.hidden = true
        cell.startTime.hidden = false
        cell.endTime.hidden = false
        cell.startTime.text = "Start: " + teamMemberDetailViewModel.getAssignmentStartDateWithTime(indexPath.row)
        cell.endTime.text =
            "End: " + teamMemberDetailViewModel.getAssignmentTargetDateWithTime(indexPath.row)
        cell.assignmentDetail.text = teamMemberDetailViewModel.getAssignmentDetail(indexPath.row)
        cell.selectionStyle = .None
        return cell
        }
        else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)  as UITableViewCell
            cell.textLabel?.text = teamMemberDetailViewModel.getCommunicateTitle(indexPath.row)
            cell.detailTextLabel?.text = ""
            cell.textLabel?.textColor = enableButtonColor
            return cell
        }
        return UITableViewCell()
    }
    
   override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
   {
     if section == 0
     {
        return "Assignments"
     }
     else if section == 1
     {
        return "Communicate"
     }
        return ""
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.section == 0
        {
        return 76
        }
        else if indexPath.section == 1
        {
        return 44
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 1
        {
            if indexPath.row == 0 {
                startConference(0)
            }
            else if indexPath.row == 1 {
                startConference(1)
            }
            else {
                print("present")
                print(projectDetailViewModel)
                
                presentProjectTeamChatViewController()
            }
        }
       memberDetailsTableview.userInteractionEnabled = false
    }
    
  
    func startConference(communicationType: Int)
    {
        if communicationType == 0{
            
            // self.callWithConferenceType(.Audio)
        }
        else if communicationType == 1{
            
            //self.callWithConferenceType(.Video)
        }
        
    }
    
    /* func callWithConferenceType(type:QBRTCConferenceType){
     
     if  communicationViewModel.isAnymemberSelected(){
     
     QBRTCClient.initializeRTC()
     QBRTCClient.instance().addDelegate(self)
     let opponentsIds =  communicationViewModel.selectedMembersUserIdsForConference()
     let session = QBRTCClient.instance().createNewSessionWithOpponents(opponentsIds, withConferenceType: type)
     if (session != nil){
     currentSession = session
     currentSession.startCall(nil)
     }
     else{
     
     print("Session Not Created Please login first")
     
     }
     
     }else{
     
     print("No Member Selected for Conference")
     }
     
     }
     
     
     func didReceiveNewSession(session: QBRTCSession!, userInfo: [NSObject : AnyObject]!) {
     
     if self.currentSession != nil{
     
     var info = Dictionary<String,String>()
     info["Key"] = "Busy"
     session.rejectCall(info)
     return
     }
     self.currentSession = session
     }
     
     func session(session: QBRTCSession!, acceptedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
     
     print("Accepted by User \(userID)")
     self.currentSession.acceptCall(userInfo)
     }
     
     func session(session: QBRTCSession!, rejectedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
     
     print("Rejected By User \(userID)")
     self.currentSession.rejectCall(userInfo)
     }*/
    
    func presentProjectTeamChatViewController()
    {
        
        func setUp(){
            
            projectTeamChatViewController.enbleAndDisable = false
            projectTeamChatViewController.allowHeaders = false
            
            SVProgressHUD.showWithStatus("Loading")
            teamMemberDetailViewModel.checkChatGroupExist(selectedMember.fullName){res,chat in
                
                if res{
                    
                    print("Chat Exist")
                    SVProgressHUD.dismiss()
                    self.projectTeamChatViewController.projectTeamChatViewModel = PLProjectTeamChatViewModel()
                    self.projectTeamChatViewController.projectTeamChatViewModel.addChatGroup(chat!)
                    self.navigationController?.pushViewController(self.projectTeamChatViewController, animated: true)
                    
                }else{
                    
                    print("Create Chat")
                    
                    SVProgressHUD.showWithStatus("Loading")
                     self.teamMemberDetailViewModel.createGroupWithMember(self.selectedMember.memberUserId, memberName: self.selectedMember.fullName, completion: { (res,group) in
                     SVProgressHUD.dismiss()
                     self.projectTeamChatViewController.projectTeamChatViewModel = PLProjectTeamChatViewModel()
                     self.projectTeamChatViewController.projectTeamChatViewModel.addChatGroup(group)
                     
                     
                     self.navigationController?.pushViewController(self.projectTeamChatViewController, animated: true)
                     
                     })
                }
            }
        }
        
        if projectTeamChatViewController == nil
        {
            projectTeamChatViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLProjectTeamChatViewController") as! PLProjectTeamChatViewController
            
            setUp()
        }
        else
        {
            setUp()
        }
        
        
        
    }
}
