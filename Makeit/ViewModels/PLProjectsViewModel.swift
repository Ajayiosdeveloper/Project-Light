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
    
    func fillProjectListArrayWithContents(container:[AnyObject])
    {
        for (i,_) in container.enumerate()
        {
            let remoteObject = container[i] as! QBCOCustomObject
            let name = remoteObject.fields!["name"] as! String
            let description = remoteObject.fields!["description"] as? String
            let project = PLProject(projectName:name, subTitle:description)
            project.projectId = remoteObject.ID
            project.createdByName = "You"
            project.createdBy = remoteObject.userID
            project.parentId = remoteObject.parentID
            createdProjectList.append(project)
        }
       
        willChangeValueForKey("createdProjectList")
        didChangeValueForKey("createdProjectList")
        
    }
    
    func fillContributionProjectsListArray(container:[AnyObject])
    {
        for (i,_) in container.enumerate()
        {
            let remoteObject = container[i] as! QBCOCustomObject
            let name = remoteObject.fields!["projectName"] as! String
            let description = remoteObject.fields!["subTitle"] as? String
            let creatorDetails  = remoteObject.fields!["creatorDetails"] as! [String]
            let project = PLProject(projectName:name, subTitle:description)
            project.projectId = remoteObject.parentID
            project.createdBy = remoteObject.userID
            project.createdAt = remoteObject.createdAt!
            project.createdByName = creatorDetails[0]
            contributingProjectList.append(project)
        }
    }
    
    func  addNewProjectToCreatedProjectList(project:PLProject?,completion:(Bool)->Void)
    {
        if let projects = project
        {
        self.createdProjectList.append(projects) // what happens with no append
        }
        print(createdProjectList.count)
        completion(true)
    }
    
    func rowsCount() -> Int {
        
        return self.createdProjectList.count
    }
    
    func contributingProjectsRowCount() -> Int {
        
        return contributingProjectList.count
    }
    
    func ProjectTitle(row : NSInteger) -> String { //change indexpath variable name
        
        let project = createdProjectList[row]
        return project.name
    }
    
    func subTitle(row: NSInteger) -> String { //change indexpath variable name
        
        let project = createdProjectList[row]
        
        if let _ = project.subTitle {
            
            return project.subTitle!
        }
        return ""
    }
    
    func projectCreatedDate(row:Int, section:Int)->String{ //rename the method
        
        if section == 0{
            let project = createdProjectList[row]
            return NSDateFormatter.localizedStringFromDate(project.createdAt, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        }else{
            let project = contributingProjectList[row]
            return NSDateFormatter.localizedStringFromDate(project.createdAt, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        }
    }
    
    func projectNameStartLetter(index:Int,section:Int)->Character{
        if section == 0{
            let project = createdProjectList[index]
            return  project.name.characters.first!
        }
        else{
            
            let project = contributingProjectList[index]
            return project.name.characters.first!
        }
    
    
    }
    
    func projectCreator(row:Int) -> String{ //rename as projectCreator
        
        let project = contributingProjectList[row]
        return "Created by : \(project.createdByName)"
    }
    
    func getViewColor()->UIColor{
        
        let arrayOfColors = [UIColor.redColor(),UIColor.blueColor(),UIColor.orangeColor(),UIColor.purpleColor(),UIColor.cyanColor(),UIColor.greenColor(),UIColor.blackColor(),UIColor.brownColor()]
        
        let i = Int(arc4random_uniform(8))
        
        return arrayOfColors[i]
    }
    
    
    func contributingProjectTitle(row:Int) -> String {
        
        let project = contributingProjectList[row]
        return project.name
    }
    
    func contributingProjectSubTitle(row:Int) -> String {
        
        let project = contributingProjectList[row]
        if let _ = project.subTitle{
            return project.subTitle!
        }
        return ""
    }
    
    func didSelectRow(index:Int,section:Int) -> PLProject {
        
        if section == 0{
            return createdProjectList[index]
        }
         return contributingProjectList[index]
        
    }
    
    func removeAllProjects() {
        
        createdProjectList.removeAll()
    }

    func logout()  { //Logout
        
        quickBloxClient.logout()
        createdProjectList.removeAll()
    }
    
    func deleteProjectInParticularRow(row : Int, completion:(Bool)->Void) {
        
        let project = self.createdProjectList[row]
        quickBloxClient.deleteProjectWithId(project.projectId!){result in
            
            if result { completion(true) }
            else { completion(false) }
    }
  }
    
    
    func getProjectMembersList(projectId:String,completion:([PLTeamMember]?)->Void) {
        
        var teamMembers:[PLTeamMember] = [PLTeamMember]()
        quickBloxClient.fetchTeamMembersOfProjectId(projectId){ members in
            
            if let _ = members{
                
                if members?.count > 0
                {
                    let first = members![0]
                    
                    let creatorDetails = first.fields?.objectForKey("creatorDetails") as! [String]
                    PLTeamMember.creatorDetails = [String:String]()
                    PLTeamMember.creatorDetails!["creatorName"] = creatorDetails[0] as String
                    PLTeamMember.creatorDetails!["creatorUserId"] = UInt(creatorDetails[1])
                    PLTeamMember.creatorDetails!["creatorAvatarFileId"] = creatorDetails[2] as String
                    PLTeamMember.creatorDetails!["creatorEmail"] = creatorDetails[3] as String
                }

                 let loggedInId = QBSession.currentSession().currentUser?.ID
               
                
                if let _ = members{
                for each in members! {
                    
                    let member_user_id = each.fields?.objectForKey("member_User_Id") as! UInt
                    if member_user_id ==  loggedInId{
                        
                        print("Remove logged in user")
                    }else{
                        
                        let member = PLTeamMember(name:"", id:0)
                        member.fullName = (each.fields?.valueForKey("name"))! as! String
                        member.projectId = projectId
                        member.profilePicture = each.fields?.valueForKey("avatar") as! String
                        member.memberId = each.ID!
                        member.memberUserId = (each.fields?.valueForKey("member_User_Id"))! as! UInt
                        member.memberEmail = each.fields?.valueForKey("memberEmail") as! String
                        teamMembers.append(member)
                    }
                }
            }
                let creatorId = PLTeamMember.creatorDetails!["creatorUserId"] as! UInt
                
                if  creatorId != loggedInId {
                  
                    let creator = PLTeamMember(name:"", id: 0)
                    creator.fullName = PLTeamMember.creatorDetails!["creatorName"] as! String
                    creator.projectId = ""
                    creator.profilePicture = PLTeamMember.creatorDetails!["creatorAvatarFileId"] as! String
                    creator.memberUserId = PLTeamMember.creatorDetails!["creatorUserId"] as! UInt
                    creator.memberEmail = PLTeamMember.creatorDetails!["creatorEmail"] as! String

                    teamMembers.insert(creator, atIndex: 0)
                }
                
                  completion(teamMembers)
                
            }
        
        }
        
    }
    
   
        func uploadUserProfilePicture(image:UIImage,completion:(Bool)->Void)
        {
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
    
    
    
    func fetchUserProfilePicture(completion:(UIImage?)->Void) {
        
      
        
        quickBloxClient.fetchUserProfilePictureWithBlobId() { result in
        
        if result != nil {
        
        let image = UIImage(data:result!)
        
        completion(image)
        }
        else { completion(nil) }
     
       }
        
    }
    
    
    func updateUserProfilePicture(image:UIImage,completion:(Bool)->Void) {
        
     quickBloxClient.updateUserProfilePictureWithBlobId(image) { result in
            
            if result {
                
                completion(true)
            }
            else{completion(false)
            
            }
        }
     }
    
    func getTodayTasksCount(completion:(String)->Void){
        
        quickBloxClient.countOfTodayCommitments(){ count in
            
            if count == 0{
                completion(String(0))
            }else{
                
                completion(String(count))
            }
         }
     }
    
    func getUpcomingTasksCount(completion:(String)->Void){
        
        quickBloxClient.countOfUpComingCommitments()
        { count in
            if count == 0{
                completion(String(0))
            }else{
                
                completion(String(count))
            }
        }
    }
    
    func getPendingTasksCount(completion:(String)->Void){
        
        quickBloxClient.countOfPendingTasks(){ count in
            if count == 0{
                completion(String(0))
            }else{
                
                completion(String(count))
            }
        }
    }
    
    func getUpcoimgBirthdaysCount(completion:(String)-> Void)
    {
        quickBloxClient.upcomingBirthdays() { count in
            if count == 0
            {
                completion(String(0))
            }
            else{
                completion(String(count))
            }
        }
    }
    
    
    func getBirthdaysCount(completion:(String)->Void){
        
        quickBloxClient.findBirthdays(){ count in
            
            if count == 0{
                completion(String(0))
            }else{
                completion(String(count))
            }
        }
    }
    
    func getTodayAssignmentsCount(completion:(String)->Void){
        
        quickBloxClient.countOfTodayAssignments(){ count in
            
            if count == 0{
                completion(String(0))
            }else{
                
                completion(String(count))
            }
        }
    }
    
    func getUpcomingAssignmentsCount(completion:(String)->Void){
        
        quickBloxClient.countOfUpComingAssignments()
            { count in
                if count == 0{
                    completion(String(0))
                }else{
                    
                    completion(String(count))
                }
        }
    }
    
    func getPendingAssignmentsCount(completion:(String)->Void){
        
        quickBloxClient.countOfPendingAssignments(){ count in
            if count == 0{
                completion(String(0))
            }else{
                
                completion(String(count))
            }
        }
    }

    
}
