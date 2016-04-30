//
//  PLTeamMemberDetailViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 23/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLTeamMemberDetailViewModel: NSObject {
    
    var memberName:String!
    var userId:UInt!
    var projectId:String!
    var assignments:[PLAssignment]!
    var communicateWays:[String] = ["Voice Call", "Video Call","Text Chat"]
    var quickBloxClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()
    init(withMemberName:String,userId:UInt,projectId:String) {
        memberName = withMemberName
        self.userId = userId
        self.projectId = projectId
        super.init()
    }
    
    func getTeamMemberName()->String{
        return self.memberName
    }
    
    func getNumberOfAssignmentRows()->Int
    {
        if let _ = assignments{
            return assignments.count
        }
        return 0
    }
    
    func  getNumberOfCommunicateRows() -> Int {
        
        return 3
    }
    
    func getAssignmentTitle(row:Int) -> String {
        
        let assignment = assignments[row]
        
        return assignment.name
    }
    
    func getCommunicateTitle(row:Int)->String{
        return communicateWays[row]
    }
    
    func getAssignmentDetail(row:Int)->String{
        
        let assignment = assignments[row]
        
        return assignment.details
    }
    
    func getAssignmentTargetDate(row:Int) -> String {
        
        let assignment = assignments[row]
        
        return assignment.targetDate
    }
    
    
    
    func getAssignmentsOfUserForProject(completion:(Bool)->Void) {
        
           quickBloxClient.fetchUserAssignmentsForProject(userId,projectId: projectId){ assignments in
            
            if let _ = assignments{
               
                self.assignments = assignments!
                completion(true)
            }
            else{self.assignments = nil; completion(false)}
        }
    }

}
