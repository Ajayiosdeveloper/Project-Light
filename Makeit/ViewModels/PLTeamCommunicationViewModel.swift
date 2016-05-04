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
    
   func contributorTitleForRowAtIndexPath(row:Int)->String{
        
        let member = teamMembersList[row]
        return member.fullName
    }
    
    
    func addTeamMemberAtRow(row:Int){
        
        self.selectedTeamMembers.append(teamMembersList[row])
        
        print(self.selectedTeamMembers)
    }
    func removeTeamMemberAtRow(row:Int) {
        
        let object = self.teamMembersList[row]
        let index = self.selectedTeamMembers.indexOf(object)
        self.selectedTeamMembers.removeAtIndex(index!)
        print(self.selectedTeamMembers)
    }
    
    func contributorImageRowAtIndexPath(row:Int,completion:(UIImage?)->Void) {
        
        let member = teamMembersList[row]
        let avatar = member.avatar
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
    
    
    func isAnymemberSelected()->Bool{
        
        if selectedTeamMembers.count > 0{
            
            return true
        }
        
        return false
    }
   
    func selectedMembersUserIdsForConference()->[UInt]{
        
        var membersUserIds = [UInt]()
        
        for member in selectedTeamMembers{
            
            membersUserIds.append(member.memberUserId)
        }
      
        return membersUserIds
    }

}
