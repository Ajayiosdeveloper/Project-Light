//
//  PLProject.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 18/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLProject: NSObject {
    
    var name:String
    var subTitle: String?
    var createdBy:UInt
    var projectId:String?
    var parentId:String?
    
    
    init(projectName:String,subTitle:String? = nil) {
        
        name = projectName
        self.subTitle = subTitle
        createdBy = 0
        projectId = nil
        parentId = nil
    }
}

class PLTeamMember: NSObject {
    
    var fullName:String
    var memberId:String
    var projectId:String
    var memberUserId:UInt
    var avatar:String
    
    init(name:String,id:UInt) {
        fullName = name
        memberId = ""
        projectId = ""
        memberUserId = 0
        avatar = ""
    }
    
}


class PLCommitment: NSObject {
    
    var name:String = ""
    var details: String = ""
    var commitmentId:String = ""
    var targetDate:String = ""
    
    
}

class PLAssignment: NSObject {
    
    var name:String = ""
    var details: String = ""
    var commitmentId:String = ""
    var targetDate:String = ""
    var assignees:[String] = [String]()
    var assineesUserIds:[UInt] = [UInt]()
}

class PLChatGroup:NSObject{
    
    var name:String = ""
    var opponents:[NSNumber] = [NSNumber]()
    var chatGroupId:String = ""
    var lastMessage:String? = ""
    var lastMessageSenderId:UInt? = 0
    var lastMessageDate:String? = ""
    
}






class PLSharedManager:NSObject{
    
    static var manager:PLSharedManager = PLSharedManager()
    
    var existingContributorsList:[PLTeamMember] = [PLTeamMember]()
    var projectName:String = ""
    var projectId:String = ""
    var groupName:String = ""
    var userPassword:String = ""
    
}

func ==(lhs:PLTeamMember,rhs:PLTeamMember) -> Bool {
    
    return (lhs.fullName == rhs.fullName && lhs.memberId == rhs.memberId)
}