//
//  AddProjectViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 18/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

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

    func createNewProjectWith(name:String,description:String){
        
        if self.selectedContributors.count == 0 {
            
            quickBloxClient.createNewProjectWith(name, description: description){[weak self]result,projectId in
                self!.isProjectCreated = result
                self!.willChangeValueForKey("isProjectCreated")
                self!.didChangeValueForKey("isProjectCreated")
            }
        }
        else{
            
            quickBloxClient.createNewProjectWith(name, description: description){[weak self]result,projectId in
                
                var qbObjects:[QBCOCustomObject] = [QBCOCustomObject]()
                
                for each in self!.selectedContributors{
                    
                   let qbCustomObject = QBCOCustomObject()
                   qbCustomObject.className = "PLProjectMember"
                   qbCustomObject.fields?.setObject(each.fullName, forKey:"name")
                   qbCustomObject.fields?.setObject(projectId, forKey:"_parent_id")
                   qbObjects.append(qbCustomObject)
                }
                
                self!.quickBloxClient.createNewProjectWithContributors(qbObjects){result in
                    
                    self!.isProjectCreated = result
                    self!.willChangeValueForKey("isProjectCreated")
                    self!.didChangeValueForKey("isProjectCreated")
               }
            }
        }
       
    }
    
    func getUsersWithName(name:String,completion:([PLTeamMember]?)->Void) {
        
        var teamMembers:[PLTeamMember] = [PLTeamMember]()
        
        quickBloxClient.getListOfUsersWithName(name){ users in
            
              if let _ = users{
                
              for qbMember in users!
              {
                if qbMember.ID != QBSession.currentSession().currentUser?.ID{
                    
                    let teamMember = PLTeamMember(name:qbMember.fullName!, id: qbMember.ID)
                    
                    print("Member id is :\(teamMember.memberId)")
                    
                    teamMembers.append(teamMember)
                }
                
            }
                
                completion(teamMembers)
                
              } else {completion(nil)}
           }
    }
    
    func numberOfRowsInTableView()->Int
    {
        return self.selectedContributors.count
    }
    
    func titleAtIndexPathOfRow(row:Int)->String
    {
        let member = selectedContributors[row]
        
        return member.fullName
    }
    
    func andOrRemoveContributor(member:PLTeamMember){
        
        if self.selectedContributors.count == 0 { self.selectedContributors.append(member)}
        else{
            
            if self.selectedContributors.contains(member){
                
               let index = self.selectedContributors.indexOf(member)
                
               self.selectedContributors.removeAtIndex(index!)
                
            }else{
                
                self.selectedContributors.append(member)
            }
        }
    }
  
    func deleteSelectedContributor(index:Int) {
        
        self.selectedContributors.removeAtIndex(index)
    }

}
