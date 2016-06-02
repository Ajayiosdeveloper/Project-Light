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
    
    func contributorImage(row:Int,completion:(UIImage?, ServerErrorHandling?)->Void) {
        
        let member = teamMembersList[row]
        let avatar = member.profilePicture
        if avatar == "Avatar"
        {
            completion(nil, nil)
        }
        else{
            
            qbClient.downloadTeamMemberAvatar(avatar){result,err in
                
                if result != nil{
                    
                    completion(result,nil)
                }
                else{
                    
                    completion(nil, err)
                }
            }
        }
    }
    
    func isMembersSelectedForChatGroup()->Bool{
        
        if selectedTeamMembers.count > 0{
            return true
        }
        return false
    }
    
    func isGroupWithSameMembersExist(groups:[PLChatGroup])->Bool{
    
        
        var membersIds = [UInt]()
        for member in selectedTeamMembers
        {
            membersIds.append(member.memberUserId)
        }
        
        membersIds.append(PLSharedManager.manager.loggedInUserId)
        
        let selectedMembersSet = NSSet(array:membersIds)
        
        for (_,v) in groups.enumerate(){
            
          let chatMembersSet = NSSet(array: v.opponents)
          
          
            if chatMembersSet.isEqualToSet(selectedMembersSet as Set<NSObject>){
                
                return true
            }
        }
        return false
    }
    
   
    func createProjectGroup(name:String,completion:(Bool,PLChatGroup?,ServerErrorHandling?)->Void){
        
        var membersIds = [UInt]()
        
        
        for member in selectedTeamMembers
        {
            membersIds.append(member.memberUserId)
            
        }
        
        
        qbClient.createChatGroupWitTeamMembers(name,projectId: PLSharedManager.manager.projectId,membersIds: membersIds, completion: { result,chatGroup,err in
            
            if result{
                
                completion(true,chatGroup,nil)
                
            }
            else{
                
                completion(false,nil,err)
            }
            
            
        })
        
    }
    
    
}
