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
    
   func createCommitmentWith(name:String,targetDate:NSDate,description:String,projectId:String,completion:(Bool)->Void){
        
        print(name)
        print(targetDate)
        print(description)
        print(projectId)
        let targetDateString = NSDateFormatter.localizedStringFromDate(targetDate, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        qbClient.createCommitmentForProject(projectId, date:targetDateString, name: name, description:description){ result in
           
            completion(result)
        }
    }
    
    func commitmentValidations(name:String,targetDate:NSDate,description:String) throws->Bool {
        
        if name.characters.count == 0 { throw CommitValidation.NameEmpty}
        let today = NSDate()
        if (targetDate.earlierDate(today).isEqualToDate(targetDate)){
            
            throw CommitValidation.InvalidDate
        }
        if description.characters.count == 0
        {
            throw CommitValidation.DescriptionEmpty
        }
       
        return true
    }
    
    func commitmentName()->String{
        
        return commitment!.name
    }
    
    func commitmentTargetDate() -> String {
        
        return commitment!.targetDate
    }
    
//    func commitmentEndDate() -> String {
//        
//        return commitment!.targetDate
//    }
    
    func commitmentDescription() -> String {
        
        return commitment!.details
    }
    
    func priorityDataCount()->Int{
        
        return 5
    }
    
    func priorityTypeForRow(row:Int)->String{
        
      let priorityType = ["Critical","Very Important","Important","Medium","Low"]
   
        return priorityType[row]
      }
    
    func addCommitmentToCalendar(name:String,date:NSDate){
        
         self.isAccessGranted(){[weak self] result in
            
            if result{
                let event = EKEvent(eventStore: self!.eventStore!)
                 event.title = name
                 event.startDate = date
                 event.endDate = event.startDate.dateByAddingTimeInterval(60*60)
                 event.calendar = self!.eventStore!.defaultCalendarForNewEvents
//                 let alarm = EKAlarm(absoluteDate: date)
//                            event.addAlarm(alarm)
                try!  self!.eventStore!.saveEvent(event, span: EKSpan.FutureEvents)
            }
            else{
                
                print("Not having permission")
            }
        }
        
    }
    
    func isAccessGranted(completion:(Bool)->Void){
    
        
         eventStore = EKEventStore()
         eventStore!.requestAccessToEntityType(
            EKEntityType.Event , completion: {(granted, error) in
                
                completion(granted)
          })
        }

}
