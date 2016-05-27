//
//  PLProjectTeamChatViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 02/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLProjectTeamChatViewModel: NSObject {
    
    var projectTeamMembers:[PLTeamMember]?
    var projectChatGroupsList:[PLChatGroup] = [PLChatGroup]()
    var qbClient = PLQuickbloxHttpClient()
    
    init(teamMembers:[PLTeamMember]?) {
        
        projectTeamMembers = teamMembers
    }
    
    func addChatGroup(group:PLChatGroup){
        
        projectChatGroupsList.append(group)
    }
    
    
    func numberOfRows()->Int{
        
        return projectChatGroupsList.count
    }
    
    func titleForRow(row:Int)->String{
        
        let group = projectChatGroupsList[row]
        return group.name
        
    }
    
    func getUnreadMessageCount(row:Int)->String{
        
        let group = projectChatGroupsList[row]
        return String(group.unReadMessageCount)
    }
    
    func detailTitle(row:Int)->String{
        
        let group = projectChatGroupsList[row]
        if let _ = group.lastMessage{
            return group.lastMessage!
        }
        return ""
    }
    
    func selectedGroup(row:Int)->PLChatGroup{
        
       PLSharedManager.manager.groupName = projectChatGroupsList[row].name
        
        return projectChatGroupsList[row]
    }
    
    func fetchChatGroups(completion:(Bool)->Void){
        
        qbClient.fetchChatGroupsForProject {[weak self] (result, chatGroups) in
            
            if result{
                
                self!.projectChatGroupsList.appendContentsOf(chatGroups)
                
                completion(true)
            }
            
        }
    }
    
    
}
