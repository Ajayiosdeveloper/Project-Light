//
//  PLProjectAssignmentViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

enum AssignmentValidation:ErrorType {
    case NameEmpty,InvalidDate,DescriptionEmpty,NoAssignee
}


class PLProjectAssignmentViewModel: NSObject {
    
    var qbClient:PLQuickbloxHttpClient!
    var assigneeList:[PLTeamMember]!
    var selectedAssigneeList:[PLTeamMember]!
    var selectedAssignment:PLAssignment?
    init(assignees:[PLTeamMember]) {
        
        assigneeList = assignees
        selectedAssigneeList = [PLTeamMember]()
    }
    
    func assignmentValidations(name:String,startDate:NSDate, targetDate:NSDate,description:String,projectId:String,assignees:[PLTeamMember]) throws->Bool {
        
        if name.characters.count == 0 { throw AssignmentValidation.NameEmpty}
        let today = NSDate()
        if (targetDate.earlierDate(today).isEqualToDate(targetDate)){
            
            throw AssignmentValidation.InvalidDate
        }
        if (startDate.earlierDate(today).isEqualToDate(startDate)){
            
            throw AssignmentValidation.InvalidDate
        }
        if description.characters.count == 0
        {
            throw AssignmentValidation.DescriptionEmpty
        }
        if  assignees.count == 0
        {
            throw AssignmentValidation.NoAssignee
        }
        return true
    }
    
    func createAssignmentForProject(id:String,name:String,startDate : NSDate?, targetDate:NSDate?,description:String,assignees:[PLTeamMember],completion:(Bool)->Void)
    {
        
        var asigneeIds:[String] = [String]()
        var assigneeUserIds:[UInt] = [UInt]()
        
        for each in assignees
        {
            asigneeIds.append(each.memberId)
            assigneeUserIds.append(each.memberUserId)
        }
        
        let startDateOfCommitment = dateFormat(startDate!)
        let targetDateOfCommitment = dateFormat(targetDate!)
        let startTimeOfCommitment = timeFormat(startDate!)
        let targetTimeOfCommitment = timeFormat(targetDate!)
        
        qbClient = PLQuickbloxHttpClient()
        qbClient.createAssignmentForProject(id,startDate: Int(startDateOfCommitment), targetDate: Int(targetDateOfCommitment), name:name, description: description, assignees:asigneeIds,assigneeUserIds:assigneeUserIds,startTime: startTimeOfCommitment, endTime: targetTimeOfCommitment,members: assignees) { (res) in
            
            completion(res)
        }
    }
    
    func dateFormat(date : NSDate) -> NSTimeInterval
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.localTimeZone().secondsFromGMT)
        
        let stringDate = dateFormatter.stringFromDate(date)
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let stringToDate = dateFormatter.dateFromString(stringDate)?.timeIntervalSince1970
        return stringToDate!
    }
    
    func timeFormat(date: NSDate) -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.stringFromDate(date)
    }

    
    func numbersOfRows()->Int
    {
        if selectedAssignment != nil
        {
            return selectedAssigneeList.count
        }
        return assigneeList.count
    }
    
    func titleOfRowAtIndexPath(row:Int)->String
    {
        if selectedAssignment != nil
        {
            let member = selectedAssigneeList[row]
            return member.fullName
        }
        let member = assigneeList[row]
        return member.fullName
    }
    
    func  emailOfRowAtIndexPath(row:Int)->String{
        
        if selectedAssignment != nil
        {
            let member = selectedAssigneeList[row]
            return member.memberEmail
        }
        let member = assigneeList[row]
        return member.memberEmail
   }
    
    func addAssignee(row:Int) {
        
        self.selectedAssigneeList.append(self.assigneeList[row])
    }
    
    func removeAssignee(row:Int)  {
        
       let object = self.assigneeList[row]
       let index = self.selectedAssigneeList.indexOf(object)
       self.selectedAssigneeList.removeAtIndex(index!)
    }
    
    func getSelectedAssigneeList() -> [PLTeamMember] {
        
        return self.selectedAssigneeList
    }
    
    func assignmentName()->String{
        
        return selectedAssignment!.name
    }
    
    func timeFormats(time: String) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let date = dateFormatter.dateFromString(time)
        
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let dateString = dateFormatter.stringFromDate(date!)
        return dateString 
    }
    
    
    func assignmentTargetDate() -> String {
        print("datestring")
        let dateStr = timeFormats(selectedAssignment!.targetDate)
        return dateStr
    }
    
    func assignmentStartDate() -> String {
        
        return selectedAssignment!.startDate
    }

    
    func assignmentDescription() -> String {
        
        return selectedAssignment!.details
    }
    
    
    func responsibleForAssigniment()  {
        
        selectedAssigneeList = [PLTeamMember]()
        let userIds = selectedAssignment?.assineesUserIds
        for userId in userIds!
        {
            for x in assigneeList{
                
                if x.memberUserId == userId
                {
                  selectedAssigneeList.append(x)
                }
            }
        }
        
        let loggedInUserid = QBSession.currentSession().currentUser?.ID
        let result = selectedAssignment?.assineesUserIds.contains(loggedInUserid!)
        if let _ = result
        {
            if result!
            {
                let user = PLTeamMember(name: "", id: 0)
                user.fullName = "Me"
                user.memberEmail = (QBSession.currentSession().currentUser?.email)!
                user.memberUserId = (QBSession.currentSession().currentUser?.ID)!
                user.avatar = (QBSession.currentSession().currentUser?.customData)!
                selectedAssigneeList.insert(user, atIndex: 0)
            }
        }
       print("Members are \(selectedAssignment?.assineesUserIds)")
       print("Status are \(selectedAssignment?.assigneeStatus)")
        
    
  }
    
    func isLoggedInUserPartOfAssignment() -> Bool {
        
        let loggedInUserid = QBSession.currentSession().currentUser?.ID
        let result = selectedAssignment?.assineesUserIds.contains(loggedInUserid!)
        return result!
    }
    
    
    func contributorImageRowAtIndexPath(row:Int,completion:(UIImage?)->Void) {
        
        if qbClient == nil{ qbClient = PLQuickbloxHttpClient()}
        
        let member:PLTeamMember!
        
        if selectedAssignment != nil
        {
            member = selectedAssigneeList[row]
            
        }else{
            member = assigneeList[row]
        }
        
        let avatar = member.avatar
        if avatar == "Avatar"
        {
            completion(nil)
        }
        else{
            
            qbClient.downloadTeamMemberAvatar(avatar){result in
                
                if result != nil{
                    
                    completion(result)
                }
                else{
                    
                    completion(nil)
                }
            }
        }
    }
    
    func getSelectedAssigneeUserId(row:Int)->UInt{
        
        let member = assigneeList[row]
        return member.memberUserId
    }
    
    func updateAssigmentStatusOfLoggedInUser(){
        
        qbClient.updateRemoteAssigmentStatus(selectedAssignment!.assignmentId)
    }
}
