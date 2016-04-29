//
//  PLProjectsViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 16/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLProjectsViewModel: NSObject {
    
     var projectList:[PLProject] = [PLProject]()
    
    var quickBloxClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()
    
   override init() {
        
        super.init()
}
   
    func fetchProjectsFromRemote() {
        projectList.removeAll(keepCapacity: true)
        quickBloxClient.fetchProjectsOfUserWith{(result) in
            
            if let _ = result{
                
                let objects = result! as [AnyObject]
                
                self.fillProjectListArrayWithContents(objects)
            }
        }
    }
    
    func fillProjectListArrayWithContents(container:[AnyObject]){
    
        for (i,_) in container.enumerate()
        {
            let remoteObject = container[i] as! QBCOCustomObject
            let name = remoteObject.fields!["name"] as! String
            let description = remoteObject.fields!["description"] as? String
            let project = PLProject(projectName:name, subTitle:description)
            project.projectId = remoteObject.ID
            project.createdBy = remoteObject.userID
            project.parentId = remoteObject.parentID
            projectList.append(project)
        }
        willChangeValueForKey("projectList")
        didChangeValueForKey("projectList")
    }
    
    
    func rowsCount() -> Int {
        
        return self.projectList.count
    }
    
    func titleAtIndexPath(indexPath:NSInteger) -> String {
        
        let project = projectList[indexPath]
        return project.name
    }
    
    func subTitleAtIndexPath(indexPath:NSInteger) -> String {
        
        let project = projectList[indexPath]
        if let _ = project.subTitle{
            return project.subTitle!
        }
        return ""
    }
    
    func didSelectRowAtIndex(index:Int) -> PLProject {
        
        return projectList[index]
    }
    
    func removeAllProjects() {
        
        projectList.removeAll()
    }

    func performLogout()  {
        
        quickBloxClient.userLogout()
        projectList.removeAll()
    }
    
    func deleteProjectAtIndexPathOfRow(row:Int,completion:(Bool)->Void) {
        
        let project = self.projectList[row]
        quickBloxClient.deleteProjectWithId(project.projectId!){result in
            
            if result { completion(true) }
            else {completion(false)}
    }
  }
    
    
    func getProjectMembersList(projectId:String,completion:([PLTeamMember]?)->Void) {
        
        var teamMembers:[PLTeamMember] = [PLTeamMember]()
        quickBloxClient.fetchTeamMembersOfProjectId(projectId){ members in
            
            if let _ = members{
                
                for each in members! {
                    
                  let member = PLTeamMember(name:"", id:0)
                  member.fullName = (each.fields?.valueForKey("name"))! as! String
                  member.projectId = projectId
                  member.avatar = each.fields?.valueForKey("avatar") as! String
                  member.memberId = each.ID!
                  member.memberUserId = (each.fields?.valueForKey("member_User_Id"))! as! UInt
                  teamMembers.append(member)
                 
                }
                   completion(teamMembers)
                }
            
            else { completion(nil) }
        }
    }
    
    func uploadUserAvatar(image:UIImage,completion:(Bool)->Void) {
        
       quickBloxClient.uploadProfilePicture(image){ res, blobId in
                
                if res
                {
                    completion(true)
                }
                else{
                    completion(false)
                }
            }
    }
    
    
    
    func fetchUserAvatar(completion:(UIImage?)->Void) {
        
        
        quickBloxClient.fetchUserAvatarWithBlobId() { result in
        
        if result != nil {
        
        let image = UIImage(data:result!)
        
        completion(image)
        }
        else{completion(nil)}
     
       }
        
    }
    
    
    func updateUserAvatar(image:UIImage,completion:(Bool)->Void) {
        
     quickBloxClient.updateUserAvatarWithBlobId(image) { result in
            
            if result {
                
                completion(true)
            }
            else{completion(false)
            
            }
        }
     }
}
