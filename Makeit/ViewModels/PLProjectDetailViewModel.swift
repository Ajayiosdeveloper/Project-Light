//
//  PLProjectDetailViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLProjectDetailViewModel: NSObject {
    
    var contributors:[PLTeamMember]!
    var commitments:[PLCommitment]!
    var assignments:[PLAssignment]!
    var communicationWays:[String]!
    var qbClient:PLQuickbloxHttpClient!
    var numberOfSections:Int!
    

    init(members:[PLTeamMember]) {
        if members.count == 0{
            contributors = [PLTeamMember]()
        }else{
           contributors = members
        }
       commitments = [PLCommitment]()
        assignments = [PLAssignment]()
        communicationWays = ["Voice Chat","Video Chat","Text Chat"]
    }
    

    func numberOfSectionsInTableView() -> Int {
        
        if numberOfSections == 0{
            return 4
        }
        
        return 3
    }
    
    func numbersOfContributors()->Int
    {
        if contributors.count > 0
        {
        return contributors.count
    }
        return 0
    }
    
    func numberOfCommitments() -> Int {
        
        return commitments.count
    }
    
    func numberOfAssignments() -> Int {
        
        return assignments.count
    }
    
    func contributorTitle(row:Int) -> String
    {
        let member = contributors[row]
        
        return member.fullName
    }
    
   func contributorEmail(row:Int) -> String
    {
        let member = contributors[row]
        
        return member.memberEmail
    }
    
    
    func isUserAssignedToAssignment(row : Int) -> Bool
    {
        let assignment = assignments[row]
        let loggedInUserid = QBSession.currentSession().currentUser?.ID
        
        let result = assignment.assineesUserIds.contains(loggedInUserid!)
        if result
        {
           return true
        }
      return false
        
    }
    
    func contributorImage(row:Int,completion:(UIImage?)->Void) {
        
        let member = contributors[row]
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
    
    
    func commitmentTitleForRowAtIndexPath(row:Int) -> String {
        
        let commitment = commitments[row]
        return commitment.name
    }
    
    func commitmentSubTitleForRowAtIndexPath(row:Int)->String
    {
        let commitment = commitments[row]
        return commitment.details
    }
    
    func assignmentTitleForRowAtIndexPath(row:Int)->String{
        
        let assignment = assignments[row]
        return assignment.name
    }
    
    func assignmentSubTitleForRowAtIndexPath(row:Int) -> String {
        
        let assignment = assignments[row]
        return assignment.details
    }
    

    func communicationType(index:Int) -> String {
        
        return communicationWays[index]
    }
    
    func getProjectContributorsList() -> [PLTeamMember] {
        
        return contributors
    }
    
    func getCommitmentsFromServer(id:String,completion:(Bool)->Void)
    {
        qbClient = PLQuickbloxHttpClient()
        
        qbClient.fetchCommitmentsForProject(id){res,commitments in
            
            if let _ = commitments{
                
                for each in commitments!{
                    
                 let commitment = PLCommitment()
                 commitment.commitmentId = each.ID!
                 commitment.name = each.fields?.objectForKey("name") as! String
                 commitment.details = (each.fields?.objectForKey("description"))! as! String
                 let targetDate  = (each.fields?.objectForKey("targetDate"))! as! NSTimeInterval
                 let startDate  = (each.fields?.objectForKey("startDate"))! as! NSTimeInterval
                commitment.isCompleted = each.fields?.objectForKey("isCompleted") as! Int
                var startTime  = (each.fields?.objectForKey("startTime"))! as! String
                var endTime  = (each.fields?.objectForKey("endTime"))! as! String
                startTime = self.timeFormat(startTime)
                endTime = self.timeFormat(endTime)
                commitment.targetDate = self.dateFormat(targetDate)
                commitment.startDate = self.dateFormat(startDate)
                commitment.startDate += " \(startTime)"
                commitment.targetDate += " \(endTime)"
                commitment.projectId = each.parentID!
                self.commitments.append(commitment)
                }
                
                completion(true)
            }else{completion(false)}
        }
    }
    
    func dateFormat(timeInterval : NSTimeInterval) -> String
    {
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.localTimeZone().secondsFromGMT)
        return dateFormatter.stringFromDate(date)
    }
    func timeFormat(time: String) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.dateFromString(time)
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.stringFromDate(time!)
    }
    
    func getAssignmentsFromRemote(id:String, completion : (Bool) -> Void)
    {
        qbClient.fetchAssignmentsForProject(id){res,assignments in
            
            if let _ = assignments
            {
                for each in assignments!
                {
                let assignment = PLAssignment()
                assignment.assignmentId = each.ID!
                assignment.name = each.fields?.objectForKey("name") as! String
                assignment.details = (each.fields?.objectForKey("description"))! as! String
                let targetDate = (each.fields?.objectForKey("targetDate"))! as! NSTimeInterval
                let startDate = (each.fields?.objectForKey("startDate"))! as! NSTimeInterval
                assignment.targetDate = self.dateFormat(targetDate)
                assignment.startDate = self.dateFormat(startDate)
                var startTime  = (each.fields?.objectForKey("startTime"))! as! String
                var endTime  = (each.fields?.objectForKey("endTime"))! as! String
                startTime = self.timeFormat(startTime)
                endTime = self.timeFormat(endTime)
                assignment.targetDate = self.dateFormat(targetDate)
                assignment.startDate = self.dateFormat(startDate)
                assignment.startDate += " \(startTime)"
                assignment.targetDate += " \(endTime)"

                assignment.assineesUserIds = (each.fields?.objectForKey("assigneeUserId"))! as! [UInt]
                let assignementStatus = (each.fields?.objectForKey("assigneeStatus"))! as! [String]
                
                    var membersStatus = [UInt]()
                    
                    for status in assignementStatus{
                     
                        let fields = status.componentsSeparatedByString("@@@")
                        let memberStatus = UInt(fields.last!)
                        membersStatus.append(memberStatus!)
                    }
                    assignment.assigneeStatus = membersStatus
                    self.assignments.append(assignment)
              }
                completion(true)

            }else {completion(false)}
         }
    }
    
    func selectedCommitment(row:Int)->PLCommitment?
    {
        if row <= self.commitments.count
        {
            return commitments[row]
        }
        return nil
    }
    
    func selectedAssignment(row:Int) -> PLAssignment? {
        
        if  row <= self.assignments.count
        {
            return assignments[row]
        }
        return nil
    }
    
    func selectedContributor(row:Int)->PLTeamMember{
        
        return contributors[row]
    }
    
}
