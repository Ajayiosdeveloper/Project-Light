//
//  PLProjectsViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 16/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox


class PLProjectsViewModel: NSObject {
    
     var createdProjectList:[PLProject] = [PLProject]()
     var contributingProjectList:[PLProject] = [PLProject]()
     var quickBloxClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()
    
   override init() {
        
        super.init()
 }
   
    func fetchProjectsFromRemote() {
        createdProjectList.removeAll(keepCapacity: true)
        contributingProjectList.removeAll(keepCapacity: true)
        quickBloxClient.fetchContributingProjectsOfUser{(res) in
            
            if let _ = res{
                self.fillContributionProjectsListArray(res!)
                
                self.quickBloxClient.fetchProjectsOfUserWith{(result) in
                    
                    if let _ = result{
                        
                        let objects = result! as [AnyObject]
                        
                        self.fillProjectListArrayWithContents(objects)
                    }
                }
                
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
            createdProjectList.append(project)
        }
       
        willChangeValueForKey("createdProjectList")
        didChangeValueForKey("createdProjectList")
        
    }
    
    func fillContributionProjectsListArray(container:[AnyObject]){
        
        for (i,_) in container.enumerate()
        {
            let remoteObject = container[i] as! QBCOCustomObject
            let name = remoteObject.fields!["projectName"] as! String
            let description = remoteObject.fields!["subTitle"] as? String
            let project = PLProject(projectName:name, subTitle:description)
            project.projectId = remoteObject.parentID
            project.createdBy = remoteObject.userID
            contributingProjectList.append(project)
        }
    }
    
    
    func rowsCount() -> Int {
        
        return self.createdProjectList.count
    }
    
    func contributingProjectsRowCount() -> Int {
        
        return contributingProjectList.count
    }
    
    func titleAtIndexPath(indexPath:NSInteger) -> String {
        
        let project = createdProjectList[indexPath]
        return project.name
    }
    
    func subTitleAtIndexPath(indexPath:NSInteger) -> String {
        
        let project = createdProjectList[indexPath]
        if let _ = project.subTitle{
            return project.subTitle!
        }
        return ""
    }
    
    func contributingProjectTitleAtIndexPath(row:Int) -> String {
        
        let project = contributingProjectList[row]
        return project.name
    }
    
    func contributingProjectSubTitleAtIndexPath(row:Int) -> String {
        
        let project = contributingProjectList[row]
        if let _ = project.subTitle{
            return project.subTitle!
        }
        return ""
    }
    
    func didSelectRowAtIndex(index:Int,section:Int) -> PLProject {
        
        if section == 0{
            return createdProjectList[index]
        }
         return contributingProjectList[index]
        
    }
    
    func removeAllProjects() {
        
        createdProjectList.removeAll()
    }

    func performLogout()  {
        
        quickBloxClient.userLogout()
        createdProjectList.removeAll()
    }
    
    func deleteProjectAtIndexPathOfRow(row:Int,completion:(Bool)->Void) {
        
        let project = self.createdProjectList[row]
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
