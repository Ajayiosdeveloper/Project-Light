//
//  PLProjectNotification.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLProjectNotification: NSObject {
    
    
    static   func sendProjectContributorNotificationToContributors(member:UInt,projectName:String,memberName:String){
    
  
    let creator = QBSession.currentSession().currentUser?.fullName
    let message = "Hi \(memberName)! you've been added to \(projectName) Project as a contributor by \(creator!)"
    let payLoad = NSMutableDictionary()
    let aps = NSMutableDictionary()
    aps.setObject("default", forKey: QBMPushMessageSoundKey)
    aps.setObject(message, forKey: QBMPushMessageAlertKey)
    aps.setObject("PROJECT", forKey: "Type")
    payLoad.setObject(aps, forKey: QBMPushMessageApsKey)
        
    let qbMessage = QBMPushMessage()
        qbMessage.payloadDict = payLoad
        QBRequest.sendPush(qbMessage, toUsers: String(member), successBlock: { (_, _) in
            
            print("Push sent succesfully")
            
            }) { (err) in
                
                print(err)
        }

    
    }
    
    
    static   func sendAssignmentNotificationToAssignees(member:UInt,assignmentName:String,projectName:String, memberName : String){
        
    
    let assigner = QBSession.currentSession().currentUser?.fullName
    let message = "Hi \(memberName)!  you've been assigned to \(assignmentName) in \(projectName) Project by \(assigner!)"
        
        let payLoad = NSMutableDictionary()
        let aps = NSMutableDictionary()
        aps.setObject("default", forKey: QBMPushMessageSoundKey)
        aps.setObject(message, forKey: QBMPushMessageAlertKey)
        aps.setObject("ASSIGNMENT", forKey: "Type")
        aps.setObject(PLSharedManager.manager.projectId, forKey: "projectId")
        aps.setObject(PLSharedManager.manager.projectName, forKey: "projectName")
        payLoad.setObject(aps, forKey: QBMPushMessageApsKey)
        
        let qbMessage = QBMPushMessage()
        qbMessage.payloadDict = payLoad
        QBRequest.sendPush(qbMessage, toUsers: String(member), successBlock: { (_, _) in
            
            print("Push sent succesfully")
            
        }) { (err) in
            
            print(err)
        }


 }
    
   static func sendBirthdayPushNotification(member:UInt,birthdayCard:Int,message:String){
    
        let sender = QBSession.currentSession().currentUser?.fullName
        let message = "\(message) by \(sender!)"
        
        let payLoad = NSMutableDictionary()
        let aps = NSMutableDictionary()
        aps.setObject("default", forKey: QBMPushMessageSoundKey)
        aps.setObject(message, forKey: QBMPushMessageAlertKey)
        aps.setObject("BIRTHDAY", forKey: "Type")
        
        switch birthdayCard {
        case 0:
            aps.setObject(String(birthdayCardOne), forKey:"birthdayCard")
        case 1:
             aps.setObject(String(birthdayCardTwo), forKey:"birthdayCard")
        case 2:
             aps.setObject(String(birthdayCardThree), forKey:"birthdayCard")
        default:
              aps.setObject(String(birthdayCardFour), forKey:"birthdayCard")
        }
        
       payLoad.setObject(aps, forKey: QBMPushMessageApsKey)
        let qbMessage = QBMPushMessage()
        qbMessage.payloadDict = payLoad
        QBRequest.sendPush(qbMessage, toUsers: String(12892475), successBlock: { (_, _) in
            
            print("Push sent succesfully")
            
        }) { (err) in
            
            print(err)
        }

    }
    
}
