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
    var assignmentRecordId:String! // For updating the logged in user assignment status in PLAssignmentMember Table
    init(assignees:[PLTeamMember]) {
        
        assigneeList = assignees
        selectedAssigneeList = [PLTeamMember]()
    }
    
    func assignmentValidations(name:String,startDate:NSDate, targetDate:NSDate,description:String,projectId:String,assignees:[PLTeamMember]) throws->Bool {
        
        if name.characters.count == 0 { throw AssignmentValidation.NameEmpty}
        
        if targetDate.isEqualToDate(startDate){
            
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
    
    func memberName(row:Int)->String
    {
        if selectedAssignment != nil
        {
            let member = selectedAssigneeList[row]
            return member.fullName
        }
        let member = assigneeList[row]
        return member.fullName
    }
    
    func  memberEmail(row:Int)->String{
        
        if selectedAssignment != nil
        {
            let member = selectedAssigneeList[row]
            return member.memberEmail
        }
        let member = assigneeList[row]
        return member.memberEmail
   }
    
    func assigneeStatus(row:Int)->String{
      
       let member = selectedAssigneeList[row] as! PLAssignmentMember
        
       return String(member.assigneeStatus)
    }
    
    func addAssignee(row:Int) {
        
        self.selectedAssigneeList.append(self.assigneeList[row])
    }
    
    func percentageCompletedByAssignee(row:Int)->CGFloat{
        let member = selectedAssigneeList[row] as! PLAssignmentMember
        return (CGFloat(member.percentageCompleted) / 100)
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
    
    func responsibleForAssigniment(completion:(Bool)->Void)  {
        
        print("Assignment Id is \(selectedAssignment?.assignmentId)")
        
       if qbClient == nil{ qbClient = PLQuickbloxHttpClient()}

        
        selectedAssigneeList = [PLTeamMember]()
        
        qbClient.getAssignmentMembersForAssignmentId(selectedAssignment!.assignmentId){ members in
            
            if let _ = members{
                
                for member in members!{
                    
                 let assignmentMember = PLAssignmentMember(name:"", id: 0)
                 assignmentMember.fullName = member.fields?.objectForKey("assigneeName") as! String
                 assignmentMember.memberUserId = member.fields?.objectForKey("assigneeUserId") as! UInt
                 assignmentMember.assigneeStatus = member.fields?.objectForKey("assigneeStatus") as! UInt
                 assignmentMember.profilePicture = member.fields?.objectForKey("Avatar") as! String
                 assignmentMember.memberEmail = member.fields?.objectForKey("assigneeEmail") as! String
                 assignmentMember.percentageCompleted = member.fields?.objectForKey("percentageCompleted") as! Int
                 assignmentMember.assignmentRecordId = member.ID!
                  if assignmentMember.memberUserId == QBSession.currentSession().currentUser?.ID{
                    
                    assignmentMember.fullName = "Me"
                     self.assignmentRecordId = member.ID!
                     self.selectedAssigneeList.insert(assignmentMember, atIndex: 0)

                    }else{
                      self.selectedAssigneeList.append(assignmentMember)
                    }
                }
                completion(true)
                print("Completion is true")
            }else{
                completion(false)
            }
        
            
        }
        
    }
    
    func isLoggedInUserPartOfAssignment() -> Bool {
        
        let loggedInUserid = QBSession.currentSession().currentUser?.ID
        let result = selectedAssignment?.assineesUserIds.contains(loggedInUserid!)
        return result!
    }
    
    func isUserCreatorOfAssignment()->Bool{
        
        if let _ = selectedAssignment{
            
            if selectedAssignment!.creatorId == PLSharedManager.manager.loggedInUserId{
                return true
            }
        }
        return false
    }
    
    func showPercentageCompletedInSlider()->Int{
        
        let member = selectedAssigneeList[0] as! PLAssignmentMember
        return member.percentageCompleted
    }
    
    func numberOfAssigneesCompletedAssignment()->Int{
        
        var completedCount = 0
        if let _ = selectedAssignment{
        for member in selectedAssigneeList{
            
            let assignmentMember = member as! PLAssignmentMember
            
            if assignmentMember.assigneeStatus != 0{
            
               completedCount += 1
            }
        }
      }
        return completedCount
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
        
        let avatar = member.profilePicture
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
    
    func selectedAssignmentStatus() -> Int {
        
        return self.selectedAssignment!.assignmentStatus
    }
    
    func updateAssigmentStatusOfLoggedInUser(status:Int,completion:(Bool)->Void){
        
        if status == -1{
            
            for member in selectedAssigneeList{
                
                let assignmentMember = member as! PLAssignmentMember
                
                if assignmentMember.assigneeStatus == 0{
                   print("Not completed")
                   completion(false)
                   return
                }
            }
            
            qbClient.closeAssignment(selectedAssignment!.assignmentId){ res in
                if res{
                    self.selectedAssignment!.assignmentStatus = -1
                    completion(res)
                }else{
                    print("Handle error")
                }
                
            }
            
            }else{
        
           qbClient.updateAssigmentStatus(assignmentRecordId,status: status){ res in
            let userAssignment = self.selectedAssigneeList[0] as! PLAssignmentMember
            userAssignment.assigneeStatus = 1
            completion(res)
        }
    }
  }
    
    func updateAssignmentPercentage(value:Int){
        
        qbClient.updateAssignmentPercentage(assignmentRecordId,value: value)
       
    }
}
