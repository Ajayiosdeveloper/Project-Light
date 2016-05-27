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
    
    var qbClient:PLQuickbloxHttpClient!
    
    init(searchMembers:[PLTeamMember]) {
        
        searchList = searchMembers
       
    }
    
    func numbersOfRows()->Int
    {
        return searchList.count
    }
    
    func titleOfRow(row: Int)->String
    {
        let member = searchList[row]
        
        return member.fullName
    }

    func emailOfRow(row :Int)->String{
        let member = searchList[row]
        
        return member.memberEmail
    }
    
    func add(row : Int)->PLTeamMember {
        
        let contributor = self.searchList[row]
        
        return contributor
        
    }
    
    func remove(row:Int) -> PLTeamMember {
        
        let contributor = self.searchList[row]
        
     

        return contributor
    }
    
    func isContributorAlreadyAdded(row:Int) -> Bool {
        
        let contributor = self.searchList[row]
        
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
    
    
    func contributorImageRow(row:Int, completion:(UIImage?)->Void) {
        
        if qbClient == nil{ qbClient = PLQuickbloxHttpClient()}
        
        let member = searchList[row]
        let avatar = member.profilePicture
        if avatar == "Avatar"
        {
            completion(nil)
        }
        else{
            
            qbClient.downloadTeamMemberAvatar(avatar){result in
                
                if result != nil{
                    
                    completion(result)
                }
                else{
                    
                    completion(nil)
                }
            }
        }
    }


}
