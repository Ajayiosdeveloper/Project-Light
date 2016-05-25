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
    var createdByName:String
    var createdAt:NSDate
    var projectId:String?
    var parentId:String?
    init(projectName:String,subTitle:String? = nil) {
        
        name = projectName
        self.subTitle = subTitle
        createdBy = 0
        createdByName = ""
        projectId = nil
        parentId = nil
        createdAt = NSDate()
    }
}

class PLTeamMember: NSObject {
    
    var fullName:String
    var memberId:String
    var projectId:String
    var memberUserId:UInt
    var memberEmail:String = ""
    var birthdayInterval:UInt = 0
    var avatar:String
    var assignmentStatus:UInt = 0

    static var creatorDetails:[String:AnyObject]?
    
    init(name:String,id:UInt) {
        fullName = name
        memberId = ""
        projectId = ""
        memberUserId = 0
        avatar = ""
        memberEmail = ""
    }
    
}
class PLCommitment: NSObject {
    
    var name:String = ""
    var details: String = ""
    var commitmentId:String = ""
    var startDate:String = ""
    var targetDate:String = ""
    var isCompleted:Int = 0
    var projectName = ""
    var projectId = ""
}

class PLAssignment: NSObject {
    
    var name:String = ""
    var details: String = ""
    var commitmentId:String = ""
    var targetDate:String = ""
    var startDate:String = ""
    var assignees:[String] = [String]()
    var assineesUserIds:[UInt] = [UInt]()
    var assigneeStatus:[UInt] = [UInt]()
}

class PLChatGroup:NSObject{
    
    var name:String = ""
    var opponents:[NSNumber] = [NSNumber]()
    var chatGroupId:String = ""
    var lastMessage:String? = ""
    var lastMessageSenderId:UInt? = 0
    var lastMessageDate:String? = ""
    var unReadMessageCount:UInt = 0
    
}
class PLSharedManager:NSObject{
    
    static var manager:PLSharedManager = PLSharedManager()
    
    var existingContributorsList:[PLTeamMember] = [PLTeamMember]()
    var projectName:String = ""
    var projectId:String = ""
    var projectCreatedByUserId:UInt = 0
    var groupName:String = ""
    var loggedInUserId : UInt = 0
    var userPassword:String = ""
    var userName:String = ""
    var priorityType:String = ""
    var isCalendarAccess = false
    
}

func ==(lhs:PLTeamMember,rhs:PLTeamMember) -> Bool {
    
    return (lhs.fullName == rhs.fullName && lhs.memberId == rhs.memberId)
}