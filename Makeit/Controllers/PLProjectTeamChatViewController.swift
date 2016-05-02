//
//  PLProjectTeamChatViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 02/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLProjectTeamChatViewController: UIViewController {
    
    var projectTeamChatViewModel:PLProjectTeamChatViewModel!
    var teamCommunicationViewController:PLTeamCommunicationViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Team Chat"
        addNewChatBarButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addNewChatBarButton(){
        
        let newGroup = UIBarButtonItem(title:"New Chat", style: UIBarButtonItemStyle.Bordered, target: self, action: #selector(PLProjectTeamChatViewController.createNewChatForProject))
        self.navigationItem.rightBarButtonItem = newGroup
    }
    
    func createNewChatForProject(){
        
        print("Show Project Members for Group selection")
        
        if teamCommunicationViewController == nil{
            
            teamCommunicationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("teamCommunicationViewController") as! PLTeamCommunicationViewController
        }
        teamCommunicationViewController.communicationType = 2
        teamCommunicationViewController.communicationViewModel = PLTeamCommunicationViewModel(members: projectTeamChatViewModel.projectTeamMembers)
        self.navigationController?.pushViewController(teamCommunicationViewController, animated: true)

        
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
