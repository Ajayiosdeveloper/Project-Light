//
//  PLProjectTeamChatViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 02/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLProjectTeamChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var chatGroupsListTableView: UITableView!
    
    var projectTeamChatViewModel:PLProjectTeamChatViewModel!
    var teamCommunicationViewController:PLTeamCommunicationViewController!
    var selectedRow = 0
    var selectedSection = 0
    var enbleAndDisable : Bool = false
    var allowHeaders:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Team Chat"
        self.chatGroupsListTableView.registerNib(UINib(nibName:"PLTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier:"Cell")
        if enbleAndDisable
        {
        addNewChatBarButton()
        }
}
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        chatGroupsListTableView.userInteractionEnabled = true
        print(projectTeamChatViewModel.projectChatGroupsList.count)
        self.chatGroupsListTableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addNewChatBarButton(){
        
        let newGroup = UIBarButtonItem(title:"New Chat", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PLProjectTeamChatViewController.createNewChatForProject))
        self.navigationItem.rightBarButtonItem = newGroup
    }
    
    
    func createNewChatForProject(){
        
        if teamCommunicationViewController == nil{
            
            teamCommunicationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("teamCommunicationViewController") as! PLTeamCommunicationViewController
            
        }
        teamCommunicationViewController.communicationType = 2
        teamCommunicationViewController.chatGroups = projectTeamChatViewModel.chatGroups()
        teamCommunicationViewController.communicationViewModel = PLTeamCommunicationViewModel(members: projectTeamChatViewModel.projectTeamMembers!)
        teamCommunicationViewController.teamChatViewController = self
        self.navigationController?.pushViewController(teamCommunicationViewController, animated: true)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if allowHeaders{
        return 2
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectTeamChatViewModel.numberOfRows(section)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 55.0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        PLDynamicEngine.animateCell(cell, withTransform: PLDynamicEngine.TransformFlip, andDuration:1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! PLTableViewCell
        cell.memberName.text = projectTeamChatViewModel.titleForRow(indexPath.section,row: indexPath.row)
        cell.memberDetail.text = projectTeamChatViewModel.detailTitle(indexPath.section,row: indexPath.row)
        let unreadMessages = projectTeamChatViewModel.getUnreadMessageCount(indexPath.section,row: indexPath.row)
        if unreadMessages == "0"
        {
            cell.messageCountLabel.hidden = true
            cell.countHostingView.hidden = true
            cell.memberDetail.textColor = UIColor.blackColor()
        }else{
            cell.messageCountLabel.hidden = false
            cell.countHostingView.hidden = false
            cell.memberDetail.textColor = enableButtonColor
            cell.messageCountLabel.text = unreadMessages
        }
       
        cell.teamMemberProfile.image = UIImage(named:"chatGroup")
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
       selectedRow = indexPath.row
       selectedSection = indexPath.section
        let user = QBUUser()
        user.ID = (QBSession.currentSession().currentUser?.ID)!
        user.password = NSUserDefaults.standardUserDefaults().valueForKey("USER_PASSWORD")! as? String
        
        if QBChat.instance().isConnected(){
             self.performSegueWithIdentifier("showChatDetail", sender: self)
        }else{

        QBChat.instance().connectWithUser(user) { (error: NSError?) -> Void in
            if error == nil{
                print("Success in connection")
                self.performSegueWithIdentifier("showChatDetail", sender: self)

            }
        }
      }
        chatGroupsListTableView.userInteractionEnabled = false
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if allowHeaders{
        if section == 0{
            return "Team Chat Groups"
        }else{
            return "Personal Chat Groups"
        }
        }
        return ""
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
           let chatDetailViewController = segue.destinationViewController as! PLChatDetailViewController
           chatDetailViewController.chatDetailViewModel = PLChatDetailViewModel(chatGroup: projectTeamChatViewModel.selectedGroup(selectedSection,row: selectedRow))
           //chatDetailViewController.selectedChatGroupIndex = selectedRow
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        SVProgressHUD.dismiss()
    }
    
    
}
