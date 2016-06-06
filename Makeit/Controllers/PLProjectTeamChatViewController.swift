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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Team Chat"
        SVProgressHUD.showWithStatus("loading")
        self.chatGroupsListTableView.registerNib(UINib(nibName:"PLTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier:"Cell")
        addNewChatBarButton()
        projectTeamChatViewModel.fetchChatGroups {[weak self] (res,err) in
            
            if res{
                SVProgressHUD.dismiss()
                self!.chatGroupsListTableView.reloadData()
              }
            else
            {    SVProgressHUD.dismiss()
                PLSharedManager.showAlertIn(self!, error: err!, title: "Error occured while fetching chat groups", message: err.debugDescription)
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        teamCommunicationViewController.communicationViewModel = PLTeamCommunicationViewModel(members: projectTeamChatViewModel.projectTeamMembers!)
        teamCommunicationViewController.teamChatViewController = self
        self.navigationController?.pushViewController(teamCommunicationViewController, animated: true)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return projectTeamChatViewModel.numberOfRows()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 55.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! PLTableViewCell
        cell.memberName.text = projectTeamChatViewModel.titleForRow(indexPath.row)
        cell.memberDetail.text = projectTeamChatViewModel.detailTitle(indexPath.row)
        let unreadMessages = projectTeamChatViewModel.getUnreadMessageCount(indexPath.row)
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
        let user = QBUUser()
        user.ID = (QBSession.currentSession().currentUser?.ID)!
        user.password = PLSharedManager.manager.userPassword
        
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
           let chatDetailViewController = segue.destinationViewController as! PLChatDetailViewController
           chatDetailViewController.chatDetailViewModel = PLChatDetailViewModel(chatGroup: projectTeamChatViewModel.selectedGroup(selectedRow))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        SVProgressHUD.dismiss()
    }
    
    
}
