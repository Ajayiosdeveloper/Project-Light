//
//  PLSidebarViewModel.swift
//  Makeit
//
//  Created by Tharani P on 18/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLSidebarViewModel: NSObject {

    var qbClient = PLQuickbloxHttpClient()
    var commitments = [PLCommitment]()
    var teamMembersForBitrhday = [PLTeamMember]()
    
    func getTodayTasks(completion:(Bool)-> Void)
    {
       let type = "startDate"
       qbClient.tasksWithType(type) { [weak self] (tasks) in
        if let _ = tasks
        {
            self!.commitments.removeAll(keepCapacity: true)
            
            self!.getCommitmentArray(tasks!, completion: { (todayTasks) in
               self!.commitments = todayTasks
                completion(true)
            })
        }
        }
    }
    
    func getUpcomingTasks(completion:(Bool)-> Void)
    {
        let type = "startDate[gt]"
        qbClient.tasksWithType(type) {[weak self] (tasks) in
            if let _ = tasks
            {
             self!.commitments.removeAll(keepCapacity: true)
                self!.getCommitmentArray(tasks!, completion: { (upComingTasks) in
                    self!.commitments = upComingTasks
                    completion(true)
                })
            }
        }
    }
    func getPendingTasks(completion:(Bool)-> Void)
    {
        let type = "targetDate[lt]"
        qbClient.tasksWithType(type) {[weak self] (tasks) in
            if let _ = tasks
            {
                self!.commitments.removeAll(keepCapacity: true)
                self!.getCommitmentArray(tasks!, completion: { (pendingTasks) in
                    self!.commitments = pendingTasks
                    completion(true)
                })
            }
        }
    }
    
    func teamMembersBirthday(row: Int) -> String
    {
        let birthdays = teamMembersForBitrhday[row]
        let birthday = timeIntervalToString(NSTimeInterval(birthdays.birthdayDate))
        return birthday
    }
    
    func getTeamMemberBirthdayListForToday(range : Int,completion:(Bool)-> Void){
        
        self.teamMembersForBitrhday.removeAll(keepCapacity: true)
        qbClient.getBirthdayListOfTeamMembers(range){ members in
            
            var birthdaysOfMembers = [PLTeamMember]()
            
            if members?.count > 0{
                
                for each in members!{
                    
                 let member = PLTeamMember(name:"", id: 0)
                 member.fullName = each.fields?.objectForKey("name") as! String
                 member.memberEmail = each.fields?.objectForKey("memberEmail") as! String
                 member.memberId = String(each.userID)
                 member.memberUserId = each.fields?.objectForKey("member_User_Id") as! UInt
                 member.avatar = each.fields?.objectForKey("avatar") as! String
                 member.birthdayDate = each.fields?.objectForKey("birthday") as! Int
                 birthdaysOfMembers.append(member)
                }
                
                self.teamMembersForBitrhday = birthdaysOfMembers
                
                completion(true)
            }
        }
    }
    
    func timeIntervalToString(timeInterval : NSTimeInterval) -> String
    {
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.localTimeZone().secondsFromGMT)
        return dateFormatter.stringFromDate(date)
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
    
    func getCommitmentArray(objects : [QBCOCustomObject], completion: ([PLCommitment])->Void)
    {
        var commitmentsArray = [PLCommitment]()
        
       if objects.count > 0
       {
        print(objects.count)
            for each in objects
            {
                let commitment = PLCommitment()
                commitment.name = each.fields?.objectForKey("name") as! String
                commitment.details = each.fields?.objectForKey("description") as! String
                let startDate = each.fields?.objectForKey("startDate") as! NSTimeInterval
                let targetDate = each.fields?.objectForKey("targetDate") as! NSTimeInterval
                var startTime  = (each.fields?.objectForKey("startTime"))! as! String
                var endTime  = (each.fields?.objectForKey("endTime"))! as! String
                startTime = self.timeFormat(startTime)
                endTime = self.timeFormat(endTime)
                commitment.projectName = (each.fields?.objectForKey("projectName"))! as! String
                commitment.targetDate = self.dateFormat( targetDate)
                commitment.startDate = self.dateFormat( startDate)
                commitment.startDate += " \(startTime)"
                commitment.targetDate += " \(endTime)"
                commitment.commitmentId = each.ID!
                commitment.projectId = each.parentID!
                commitment.isCompleted = each.fields?.objectForKey("isCompleted") as! Int
                commitmentsArray.append(commitment)
            }
          completion(commitmentsArray)
        }
        
    }
    
    func getSelectedCommitment(row:Int)->PLCommitment{
        
        let commitment = commitments[row]
        return commitment
    }
    
    func projectIdForSelectedCommitement(row : Int) -> String
    {
        let commitment = commitments[row]
        return commitment.projectId
    }
    
    func numbersOfRows()->Int
    {
        if commitments.count > 0
        {
        return commitments.count
        }
        return 0
    }
    
    func titleOfRowAtIndexPath(row:Int)->String
    {
        let commitment = commitments[row]
        return commitment.name
    }
    
    func projectTitleOfRowAtIndexPath(row:Int)->String
    {
        let commitment = commitments[row]
        return commitment.projectName
    }
    
    func commitmentDetails(row:Int)->String
    {
        let commitment = commitments[row]
        return commitment.details
    }
    
    func startTaskDate(row : Int) -> String
    {
        let commitment = commitments[row]
        let startTime =  stringDate(commitment.startDate)
        return startTime
    }
    
    func endTaskDate(row : Int) -> String
    {
        let commitment = commitments[row]
        let targetTime =  stringDate(commitment.targetDate)
        return targetTime
    }
    
    func startTimeOfTask(row: Int) -> String
    {
        let commitment = commitments[row]
        let startTime =  timeFormats(commitment.startDate)
        return startTime
    }
    
    func endTimeOfTask(row:Int) -> String
    {
        let commitment = commitments[row]
        let targetTime =  timeFormats(commitment.targetDate)
        return targetTime
    }
    
    func stringDate(dateTime : String) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let date = dateFormatter.dateFromString(dateTime)
        
        dateFormatter.dateFormat = "dd/MM/yy hh:mm a"
        let dateString = dateFormatter.stringFromDate(date!)
        return dateString
    }
    
    func timeFormats(time: String) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let date = dateFormatter.dateFromString(time)
        
        dateFormatter.dateFormat = "hh:mm a"
        let dateString = dateFormatter.stringFromDate(date!)
        return dateString
    }
    
    func numberOfBirthdayRows() -> Int {
        
        if self.teamMembersForBitrhday.count > 0{
            return self.teamMembersForBitrhday.count
        }
        return 0
    }
    
    func birthdayMemberName(row:Int) -> String {
        
        let member = self.teamMembersForBitrhday[row]
        return member.fullName
        
    }
    func birthdayMemberEmail(row:Int)->String{
        let member = self.teamMembersForBitrhday[row]
        return member.memberEmail
    }
    
    
    
    func contributorImageRowAtIndexPath(row:Int,completion:(UIImage?)->Void) {
        
        let member = teamMembersForBitrhday[row]
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
    
}
