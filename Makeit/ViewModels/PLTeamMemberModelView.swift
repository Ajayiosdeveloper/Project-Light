//
//  PLTeamMemberModelView.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 20/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLTeamMemberModelView: NSObject {
    
    var searchList:[PLTeamMember]!
 
    
    init(searchMembers:[PLTeamMember]) {
        
        searchList = searchMembers
       
    }
    
    func numbersOfRows()->Int
    {
        return searchList.count
    }
    
    func titleOfRowAtIndexPath(row:Int)->String
    {
        let member = searchList[row]
        
        return member.fullName
    }

    
    func add(index:Int)->PLTeamMember {
        
        let contributor = self.searchList[index]
        
        return contributor
        
    }
    
    func remove(index:Int)->PLTeamMember {
        
        let contributor = self.searchList[index]

        return contributor
    }
    
    func isContributorAlreadyAdded(index:Int) -> Bool {
        
        let contributor = self.searchList[index]
        
        let existingContributors = PLSharedManager.manager.existingContributorsList
        
        for each in existingContributors
        {
            if each.memberUserId == contributor.memberUserId
            {
                
                return true
            }
        }
        
       return false
    }

}
