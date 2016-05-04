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
    
    func detailTitleForRow(row:Int)->String{
        
        let group = projectChatGroupsList[row]
        return group.lastMessage
    }
    
    
}
