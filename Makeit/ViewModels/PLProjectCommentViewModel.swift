//
//  PLProjectCommentViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import EventKit

enum CommitValidation:ErrorType {
    case NameEmpty,InvalidDate,DescriptionEmpty
}

///

class PLProjectCommentViewModel: NSObject {
    var eventStore:EKEventStore? = nil

    var qbClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()
    var commitment:PLCommitment?
    
    func createCommitmentWith(name:String,startDate:NSDate,targetDate:NSDate, description:String,projectId:String,identifier:String,completion:(Bool, ServerErrorHandling?)->Void)
    {
        let startDateOfCommitment = dateFormat(startDate)
        let targetDateOfCommitment = dateFormat(targetDate)
        let startTimeOfCommitment = timeFormat(startDate)
        let targetTimeOfCommitment = timeFormat(targetDate)
        

        qbClient.createCommitmentForProject(projectId,startDate:Int(startDateOfCommitment) , targetDate:Int(targetDateOfCommitment),name: name, description:description, startTime: startTimeOfCommitment, endTime:targetTimeOfCommitment,identifier: identifier){ result,ServerErrorHandling in
             if !result{
              completion(false, ServerErrorHandling)
            }
            else
            {
               completion(result, nil)
            }
            
        }
    }
    
    func updateCommitmentWith(name:String,startDate:NSDate,targetDate:NSDate, description:String,projectId:String,completion:(Bool)->Void)
    {
        print("date start")
        print(startDate)
        print(commitment?.name)
       print(dateToString(startDate))
        print(dateToString(targetDate))
        
        commitment?.name = name
        commitment?.startDate = dateToString(startDate)
        commitment?.targetDate = dateToString(targetDate)
        commitment?.details = description
        
        print(commitment?.startDate)
        print(commitment?.targetDate)
        qbClient.updateCommitmentTask(commitment!) { (res,error) in
            print("Cammmme")
           completion(res)
        }
    }
    
    
    func timeIntervalToString(timeInterval : NSTimeInterval) -> String
    {
        print("Start** **timeInterval" , timeInterval)
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.localTimeZone().secondsFromGMT)
        return dateFormatter.stringFromDate(date)
    }
    
    
    func dateFormat(date : NSDate) -> NSTimeInterval
    {
        print("Start** **date" , date)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.localTimeZone().secondsFromGMT)
 
        let stringDate = dateFormatter.stringFromDate(date)
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let stringToDate = dateFormatter.dateFromString(stringDate)?.timeIntervalSince1970        
        return stringToDate!
    }
    
    func completedTask(completion:(Bool, ServerErrorHandling?)->Void)
    {
        qbClient.updateCommitmentTask(commitment!) { (result,error) in
            completion(result, nil)
            if !result
            {
                completion(false, error)
            }
        }
    }
    
    
    func timeFormat(date: NSDate) -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.stringFromDate(date)
    }
    
    func commitmentValidations(name:String,startDate:NSDate,targetDate:NSDate,description:String) throws->Bool {
        
        if name.characters.count == 0
        {
            throw CommitValidation.NameEmpty
        }
        if #available(iOS 8.0, *) {
            if NSCalendar.currentCalendar().isDateInToday(targetDate){
                print("Today Date")
            }else{
                
                let today = NSDate()
                if (targetDate.earlierDate(today).isEqualToDate(targetDate)){
                    
                    throw CommitValidation.InvalidDate
                }
            }
        } else {
            
            let today = NSDate()
            if (targetDate.earlierDate(today).isEqualToDate(targetDate)){
                
                throw CommitValidation.InvalidDate
            }

        }
        if description.characters.count == 0
        {
            throw CommitValidation.DescriptionEmpty
        }
       
        return true
    }
    
    func updateCommitmentStatus(completion:(Bool, ServerErrorHandling?)->Void)
    {
       
        commitment?.isCompleted = 1
        self.completedTask({ (result,error) in
            if result
            {
                completion(result,nil)
            }
            else
            {
                completion(false,error)
            }
        })

    }
    
    func commitmentName()->String{
        
        return commitment!.name
    }
    
    func commitmentEndDate() -> String {
        
        return commitment!.targetDate
    }
    
    func commitmentStartDate() -> String {
        
        return commitment!.startDate
    }
    
    func commitmentDescription() -> String {
        
        return commitment!.details
    }
    
    func commitmentId() -> String {
        
        return commitment!.commitmentId
    }
    
    func commitmentStatus() -> Int {
        
        return commitment!.isCompleted
    }
    
    func priorityDataCount()->Int{
        
        return 5
    }
    
    func priorityTypeForRow(row:Int) -> String{
        
      let priorityType = ["Critical","Very Important","Important","Medium","Low"]
   
        return priorityType[row]
      }
    
    func addCommitmentToCalendar(name:String,date:NSDate,endDate:NSDate,description:String,completion:(String)->Void){
        
         self.isAccessGranted(){[weak self] result in
            
            if result{
           
                 let event = EKEvent(eventStore: self!.eventStore!)
                 event.title = name
                 event.startDate = date
                 event.endDate = endDate
                event.notes = description
                 event.calendar = self!.eventStore!.defaultCalendarForNewEvents
                do{
                    try  self!.eventStore?.saveEvent(event, span: .ThisEvent , commit: true)
                    
                    completion(event.eventIdentifier)
                }
                catch{
                    
                    
                }
            }
            else{
                
                print("Not having permission")
            }
        }
        
    }
    
//    func updateCommitmentInCalendar(event:EKEvent){
//        
//      try! self.eventStore?.saveEvent(event, span: EKSpan.ThisEvent)
//    
//    }
    
    func isAccessGranted(completion:(Bool)->Void){
    
        
         eventStore = EKEventStore()
         eventStore!.requestAccessToEntityType(
            EKEntityType.Event , completion: {(granted, error) in
                
                completion(granted)
          })
    }
    func dateToString(dateTime : NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
       return dateFormatter.stringFromDate(dateTime)
        
    }

}
