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
    var profilePicture:String
    var birthdayDate = 0
    static var creatorDetails:[String:AnyObject]?
    
    init(name:String,id:UInt) {
        fullName = name
        memberId = ""
        projectId = ""
        memberUserId = 0
        profilePicture = ""
        memberEmail = ""
        birthdayDate = 0
    }
    
}

class PLAssignmentMember:PLTeamMember{
    
    var assignmentRecordId:String = ""
    var assigneeStatus: UInt = 0
    var percentageCompleted:Int = 0
   
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
    var projectName = ""
    var assignmentId:String = ""
    var targetDate:String = ""
    var startDate:String = ""
    var creatorId:UInt = 0
    var assignmentStatus:Int = 0
    var percentageCompleted:Int = 0
    var assignees:[String] = [String]()
    var assineesUserIds:[UInt] = [UInt]()
}

struct PLChatGroup{
    
    var name:String = ""
    var opponents:[UInt] = [UInt]()
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
    
    class func showAlertIn(controller : UIViewController, error :ServerErrorHandling,title : String,message: String)
    {
        switch error {
        case .BadRequest:
            print("1")
              showAlertWithMessage(title, message: message, controller: controller)
        case .ServerError:
             print("2")
              showAlertWithMessage(title, message: message, controller: controller)
        case .StatusCodeValidationFailed:
            print("3")
            showAlertWithMessage(title, message: message, controller: controller)
        case .UnAuthorized:
             print("4")
              showAlertWithMessage(title, message: message, controller: controller)
        default:
              showAlertWithMessage(title, message: message, controller: controller)
             print("5")
        }
    }
  
   class func showAlertWithMessage(title:String,message:String,controller : UIViewController)
    {
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            alertController.addAction(action)
            controller.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertView(title: title, message: message, delegate:nil, cancelButtonTitle:"Ok", otherButtonTitles:"") as UIAlertView
            alert.show()
            
            // Fallback on earlier versions
        }
    }
    
}

func ==(lhs:PLTeamMember,rhs:PLTeamMember) -> Bool {
    
    return (lhs.fullName == rhs.fullName && lhs.memberId == rhs.memberId)
}

//To handle ServerSide Errors


public enum ServerErrorHandling
{
    case  BadRequest
    case ServerError
    case UnAuthorized
    case StatusCodeValidationFailed
    case Other
}
