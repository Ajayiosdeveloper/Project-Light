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
    
    
 static   func sendProjectContributorNotificationToContributors(members:[UInt],projectName:String){
    
    var usersString = ""
    let creator = QBSession.currentSession().currentUser?.fullName
    let message = "Hi! you've been added to \(projectName) as a contributor by \(creator!)"
    
    for each in members{
        usersString += String(each)
        usersString += ","
    }
    QBRequest.sendPushWithText(message, toUsers: usersString, successBlock: { (_, _) in
        
        print("Push sent succesfully")
        
    }) { (error) in
        
        print("Error occured")
        print(error)
    }
    }
    
    
 static   func sendAssignmentNotificationToAssignees(members:[UInt],assignmentName:String,projectName:String){
        
    var usersString = ""
    let assigner = QBSession.currentSession().currentUser?.fullName
    let message = "Hi! you've been assigned to \(assignmentName) in \(projectName) by \(assigner!)"
    
    for each in members{
        usersString += String(each)
        usersString += ","
    }
    QBRequest.sendPushWithText(message, toUsers: usersString, successBlock: { (_, _) in
        
        print("Push sent succesfully")
        
        }) { (error) in
            
          print("Error occured")
          print(error)
    }
 }
    
}
