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
    
    func getTeamMemberBirthdayListForToday(completion:(Bool)-> Void){
        
        self.teamMembersForBitrhday.removeAll(keepCapacity: true)
        qbClient.getBirthdayListOfTeamMembers(){ members in
            
            var birthdaysOfMembers = [PLTeamMember]()
            
            if members?.count > 0{
                
                for each in members!{
                    
                 let member = PLTeamMember(name:"", id: 0)
                 member.fullName = each.fields?.objectForKey("name") as! String
                 member.memberEmail = each.fields?.objectForKey("memberEmail") as! String
                 member.memberId = String(each.userID)
                 member.memberUserId = each.fields?.objectForKey("member_User_Id") as! UInt
                 member.avatar = each.fields?.objectForKey("avatar") as! String
                 birthdaysOfMembers.append(member)
                }
                
                self.teamMembersForBitrhday = birthdaysOfMembers
                
                completion(true)
            }
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
    
    func getCommitmentArray(objects : [QBCOCustomObject], completion: ([PLCommitment])->Void)
    {
        var commitments = [PLCommitment]()
        
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
                commitment.targetDate = self.dateFormat( targetDate)
                commitment.startDate = self.dateFormat( startDate)
                commitment.startDate += " \(startTime)"
                commitment.targetDate += " \(endTime)"
                commitment.commitmentId = each.ID!
                commitment.isCompleted = each.fields?.objectForKey("isCompleted") as! Int
                commitments.append(commitment)
            }
          completion(commitments)
        }
        
    }
    
    func numbersOfRows()->Int
    {
        return 7
    }
    
    func titleOfRowAtIndexPath(row:Int)->String
    {
      var taskList = [AnyObject]()
       
       for data in commitments
       {
        taskList.append(data.name)
       }
       return taskList[row] as! String
    }
    
    func detailTitleOfRowAtIndexPath(row:Int)->String
    {
        var taskDetails = [AnyObject]()
        for data in commitments
        {
            taskDetails.append(data.details)
        }
        return taskDetails[row] as! String
    }
    
    func numberOfBirthdayRows() -> Int {
        
        return 10
    }
    
    
}
