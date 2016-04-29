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
    var assignments:[PLAssignment]!
    var quickBloxClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()
    init(withMemberName:String,userId:UInt,projectId:String) {
        memberName = withMemberName
        super.init()
        getAssignmentsOfUserForProject(userId, projectId: projectId)
        
    }
    
    func getTeamMemberName()->String{
        return self.memberName
    }
    func getAssignmentsOfUserForProject(userId:UInt,projectId:String) {
        
   
        
        quickBloxClient.fetchUserAssignmentsForProject(userId,projectId: projectId){ assignments in
            
            if let _ = assignments{
               
                self.assignments = assignments!
            }
            
            else{self.assignments = nil}
        }
    }

}
