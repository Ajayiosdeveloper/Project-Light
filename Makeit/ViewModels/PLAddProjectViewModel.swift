//
//  AddProjectViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 18/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLAddProjectViewModel: NSObject {
    
    var selectedContributors:[PLTeamMember]!
    var quickBloxClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()
    var isProjectCreated:Bool = false
    
    override init() {
        
        selectedContributors = [PLTeamMember]()
   }
    
    func validateProjectDetails(name:String) -> Bool {
        
        if name.characters.count == 0
        {
            return false
        }
       return true
    }

    func createNewProjectWith(name:String, description:String, completion:(PLProject?)->Void){
        
        if self.selectedContributors.count == 0 {
            
            quickBloxClient.createNewProjectWith(name, description: description){result,projectId in
                if result{
                let addedProject = PLProject(projectName: name, subTitle:description)
                addedProject.projectId = projectId
                addedProject.createdBy = (QBSession.currentSession().currentUser?.ID)!
                completion(addedProject)
                }else{completion(nil)}

            }
        }
        else{
            
            quickBloxClient.createNewProjectWith(name, description: description){[weak self]result,projectId in
                
                var qbObjects:[QBCOCustomObject] = [QBCOCustomObject]()
                
                for each in self!.selectedContributors{
                    
                   let qbCustomObject = QBCOCustomObject()
                   qbCustomObject.className = "PLProjectMember"
                   qbCustomObject.fields?.setObject(name, forKey:"projectName")
                   qbCustomObject.fields?.setObject(description, forKey:"subTitle")
                   qbCustomObject.fields?.setObject(each.fullName, forKey:"name")
                   qbCustomObject.fields?.setObject(each.profilePicture, forKey:"avatar")
                   qbCustomObject.fields?.setObject(each.memberEmail, forKey:"memberEmail")
                   qbCustomObject.fields?.setObject(each.memberUserId, forKey: "member_User_Id")
                   qbCustomObject.fields?.setObject(each.birthdayInterval, forKey:"birthday" )

                   qbCustomObject.fields?.setObject(projectId, forKey:"_parent_id")
                   let creatorDetails:[AnyObject] = [(QBSession.currentSession().currentUser?.fullName)!, (QBSession.currentSession().currentUser?.ID)!,(QBSession.currentSession().currentUser?.customData)!,(QBSession.currentSession().currentUser?.email)!]
                   qbCustomObject.fields?.setObject(creatorDetails, forKey:"creatorDetails")
                   qbObjects.append(qbCustomObject)
                }
                
                self!.quickBloxClient.createNewProjectWithContributors(qbObjects){result in
                    
                    let addedProject = PLProject(projectName: name, subTitle:description)
                    addedProject.projectId = projectId
                    addedProject.createdAt = NSDate()
                    addedProject.createdBy = (QBSession.currentSession().currentUser?.ID)!
                    completion(addedProject)
                    print("Added Project \(addedProject.projectId)")

               }
            }
        }
       
    }
    
    func addContributorsToExistingProject(id:String, des:String, completion:([PLTeamMember]) -> Void)
    {
        
                var qbObjects:[QBCOCustomObject] = [QBCOCustomObject]()
        
        for each in self.selectedContributors{
            
            let qbCustomObject = QBCOCustomObject()
            qbCustomObject.className = "PLProjectMember"
            qbCustomObject.fields?.setObject(PLSharedManager.manager.projectName, forKey:"projectName")
            qbCustomObject.fields?.setObject(des, forKey:"subTitle")
            qbCustomObject.fields?.setObject(each.fullName, forKey:"name")
            qbCustomObject.fields?.setObject(each.memberUserId, forKey: "member_User_Id")
            qbCustomObject.fields?.setObject(each.birthdayInterval, forKey:"birthday" )
            qbCustomObject.fields?.setObject(each.profilePicture, forKey:"avatar")
            qbCustomObject.fields?.setObject(each.memberEmail, forKey:"memberEmail")
            qbCustomObject.fields?.setObject(id, forKey:"_parent_id")
            let creatorDetails:[AnyObject] = [(QBSession.currentSession().currentUser?.fullName)!, (QBSession.currentSession().currentUser?.ID)!,(QBSession.currentSession().currentUser?.customData)!,(QBSession.currentSession().currentUser?.email)!]
            qbCustomObject.fields?.setObject(creatorDetails, forKey:"creatorDetails")
            qbObjects.append(qbCustomObject)
            }
        
        self.quickBloxClient.createNewProjectWithContributors(qbObjects){result in
            
            var members:[PLTeamMember] = [PLTeamMember]()
            
            for each in qbObjects{
                
                let name = (each.fields?.objectForKey("name"))! as! String
                let teamMember = PLTeamMember(name:name, id:0)
                teamMember.memberUserId = (each.fields?.objectForKey("member_User_Id"))! as! UInt
                teamMember.profilePicture = each.fields?.objectForKey("avatar") as! String
                teamMember.memberEmail = each.fields?.objectForKey("memberEmail") as! String
                members.append(teamMember)
            }
            
            completion(members)

        }
        
    }
    
    
    func getUsersWithName(name:String,completion:([PLTeamMember]?)->Void) {
        
        var teamMembers:[PLTeamMember] = [PLTeamMember]()
        
        quickBloxClient.getListOfUsersWithName(name){ users in
            
              if let _ = users{
                
              for qbMember in users!
              {
                if qbMember.ID != QBSession.currentSession().currentUser?.ID && qbMember.ID != 11626865{
                    
                    let teamMember = PLTeamMember(name:qbMember.fullName!, id: qbMember.ID)
                    teamMember.memberUserId = qbMember.ID
                    teamMember.profilePicture = qbMember.customData!
                    teamMember.memberEmail = qbMember.email!
                    teamMember.birthdayInterval = UInt(qbMember.phone!)!
                    teamMembers.append(teamMember)
                }
            }
                
                completion(teamMembers)
                
              } else {completion(nil)}
           }
    }
    
    func numberOfRows()->Int
    {
        return self.selectedContributors.count
    }
    
    func projectTitle(row:Int)->String
    {
        let member = selectedContributors[row]
        
        return member.fullName
    }
    
    func memberEmailid(row:Int)->String
    {
        let member = selectedContributors[row]
        
        return member.memberEmail
    }
    
    func removeContributor(member:PLTeamMember)->Bool{
        
        if self.selectedContributors.count == 0 { self.selectedContributors.append(member)}
        else{
            
            for contributor in selectedContributors
            {
                if contributor.memberUserId == member.memberUserId{
                    
                   return false
                }
            }
           self.selectedContributors.append(member)
        }
        
        return true
    }
  
    func deleteSelectedContributor(row: Int) {
        
        self.selectedContributors.removeAtIndex(row)
    }
    
    func contributorImage(row:Int, completion:(UIImage?)->Void) {
        
        let member = selectedContributors[row]
        let avatar = member.profilePicture
        if avatar == "Avatar"
        {
            completion(nil)
        }
        else{
            
            quickBloxClient.downloadTeamMemberAvatar(avatar){result in
                
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
