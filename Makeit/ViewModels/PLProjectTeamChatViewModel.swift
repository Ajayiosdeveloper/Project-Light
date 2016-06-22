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
    var personalChatGroupList:[PLChatGroup] = [PLChatGroup]()
    var qbClient = PLQuickbloxHttpClient()
    
    override init() {
        
    }
    
    init(teamMembers:[PLTeamMember]?) {
        
        projectTeamMembers = teamMembers
    }
    
    func addChatGroup(group:PLChatGroup){
        
        projectChatGroupsList.append(group)
    }
    
    func chatGroups()->[PLChatGroup]{
    
        return projectChatGroupsList
    
    }
    
    func numberOfRows(section:Int)->Int{
        if section == 0{
        return projectChatGroupsList.count
        }
        return personalChatGroupList.count
    }
    
    func titleForRow(section:Int,row:Int)->String{
        if section == 0{
        let group = projectChatGroupsList[row]
        return group.name
        }else{
            
            let group = personalChatGroupList[row]
            return group.name
        }
    }
    
    func getUnreadMessageCount(section:Int,row:Int)->String{
        if section == 0{
        let group = projectChatGroupsList[row]
        return String(group.unReadMessageCount)
        }else{
            let group = personalChatGroupList[row]
            return String(group.unReadMessageCount)
        }
    }
    
    func detailTitle(section:Int,row:Int)->String{
        if section == 0{
        let group = projectChatGroupsList[row]
        if let _ = group.lastMessage{
            return group.lastMessage!
        }
        }
        else{
            
            let group = personalChatGroupList[row]
            if let _ = group.lastMessage{
                return group.lastMessage!
            }
        }
        
        
        
        return ""
    }
    
    func selectedGroup(section:Int,row:Int)->PLChatGroup{
        if section == 0{
       PLSharedManager.manager.groupName = projectChatGroupsList[row].name
        
        return projectChatGroupsList[row]
        }else{
            
            PLSharedManager.manager.groupName = personalChatGroupList[row].name
            
            return personalChatGroupList[row]
        }
    }
    
    func fetchChatGroups(completion:(Bool, ServerErrorHandling?)->Void){
        
        qbClient.fetchChatGroupsForProject {[weak self] (result, chatGroups,personalChatGroups,err) in
            
            if result{
                
                self!.projectChatGroupsList.appendContentsOf(chatGroups)
                self!.personalChatGroupList.appendContentsOf(personalChatGroups)
                print("Total chats count are")
                print(chatGroups.count)
                print(personalChatGroups.count)
                
                completion(true, nil)
            }
            else{
                completion(false, err)
            }
        }
    }
    
    
}
