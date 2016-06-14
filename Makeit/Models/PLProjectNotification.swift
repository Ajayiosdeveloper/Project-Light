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
    
  
    
    QBRequest.sendPushWithText(message, toUsers:String(member), successBlock: { (_, _) in
        
        print("Push sent succesfully")
        
    }) { (error) in
        
        print("Error occured")
        print(error)
    }
    }
    
    
    static   func sendAssignmentNotificationToAssignees(member:UInt,assignmentName:String,projectName:String, memberName : String){
        
    
    let assigner = QBSession.currentSession().currentUser?.fullName
    let message = "Hi \(memberName)!  you've been assigned to \(assignmentName) in \(projectName) Project by \(assigner!)"
    
    QBRequest.sendPushWithText(message, toUsers:String(member), successBlock: { (_, _) in
        
        print("Push sent succesfully")
        
        }) { (error) in
            
          print("Error occured")
          print(error)
    }
 }
    
}
