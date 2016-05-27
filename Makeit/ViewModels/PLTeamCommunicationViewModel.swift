//
//  PLTeamCommunicationViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 30/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLTeamCommunicationViewModel: NSObject {
    
    var teamMembersList:[PLTeamMember]!
    var selectedTeamMembers:[PLTeamMember] = [PLTeamMember]()
    var qbClient = PLQuickbloxHttpClient()
    
    init(members:[PLTeamMember]) {
        
        teamMembersList = members
    }
    
    func numberOfRows()->Int{
        
        if let _ = teamMembersList{
            return teamMembersList.count
        }
        
        return 0
    }
    
    func contributorTitle(row:Int)->String{
        
        let member = teamMembersList[row]
        return member.fullName
    }
    func contributorEmail(row:Int) -> String
    {
        let member = teamMembersList[row]
        return member.memberEmail
    }

    
    func addTeamMember(row:Int){
        
        self.selectedTeamMembers.append(teamMembersList[row])
        
        print(self.selectedTeamMembers)
    }
    func removeTeamMember(row:Int) {
        
        let object = self.teamMembersList[row]
        let index = self.selectedTeamMembers.indexOf(object)
        self.selectedTeamMembers.removeAtIndex(index!)
        print(self.selectedTeamMembers)
    }
    
    func contributorImage(row:Int,completion:(UIImage?)->Void) {
        
        let member = teamMembersList[row]
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
    
   
    func createProjectGroup(name:String,completion:(Bool,PLChatGroup?)->Void){
        
        var membersIds = [UInt]()
        
        
        for member in selectedTeamMembers
        {
            membersIds.append(member.memberUserId)
            
        }
        
        
        qbClient.createChatGroupWitTeamMembers(name,membersIds: membersIds, completion: { result,chatGroup in
            
            if result{
                
                completion(true,chatGroup)
                
            }
            else{
                
                completion(false,nil)
            }
            
            
        })
        
    }
    
    
}
