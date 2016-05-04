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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Team Chat"
        self.chatGroupsListTableView.registerNib(UINib(nibName:"PLTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier:"Cell")
        addNewChatBarButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(projectTeamChatViewModel.projectChatGroupsList.count)
        chatGroupsListTableView.reloadData()
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
        
        print("Show Project Members for Group selection")
        
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
        cell.memberDetail.text = projectTeamChatViewModel.detailTitleForRow(indexPath.row)
        cell.teamMemberProfile.image = UIImage(named:"chatGroup")
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
       self.performSegueWithIdentifier("showChatDetail", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
     
        
        
        
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
