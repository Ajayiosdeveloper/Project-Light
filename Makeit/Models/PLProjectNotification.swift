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
        
        for member in members{
            
            let pushMessage = "Hi Brother! you become now a contributor to \(projectName) Project by \(QBSession.currentSession().currentUser?.fullName!)"
            
            QBRequest.sendPushWithText(pushMessage, toUsers:String(member), successBlock: { (_, _) in
                
                print("Success")
                
                }, errorBlock: { (err) in
                    
                    print(err)
            })
        }
    }
    
    
 static   func sendAssignmentNotificationToAssignees(members:[UInt],assignmentName:String,projectName:String){
        
        for member in members{
            
            let pushMessage = "Hi Brother! you got an assignment in \(projectName) Project by \(QBSession.currentSession().currentUser?.fullName!)"
            
            QBRequest.sendPushWithText(pushMessage, toUsers:String(member), successBlock: { (_, _) in
                
                print("Success")
                
                }, errorBlock: { (err) in
                    
                    print(err)
            })
        }
    }
    
}
