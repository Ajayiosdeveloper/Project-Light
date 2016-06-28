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
     var todayBirthdays = [PLTeamMember]()
     var upComingBirthdays = [PLTeamMember]()
   override init() {
        
        super.init()
 }
   
    func fetchProjectsFromServer() {
        createdProjectList.removeAll(keepCapacity: true)
        contributingProjectList.removeAll(keepCapacity: true)
        
        quickBloxClient.fetchContributingProjectsOfUser{(res, serverError) in
            
            if let _ = res
            {
                self.fillContributionProjectsListArray(res!)
                
                self.quickBloxClient.fetchProjectsOfUserWith{(result, serverError) in
                    
                    if let _ = result{
                        
                        let objects = result! as [AnyObject]
                        
                        self.fillProjectListArrayWithContents(objects)
                    }
                }
            }
            if (serverError != nil)
            {
                
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
            project.createdByName = remoteObject.fields!["projectCreatorName"] as! String/////"You"
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
    
    func ProjectTitle(row : NSInteger) -> String {
        
        let project = createdProjectList[row]
        
        if  project.name != "" {
            
            return project.name
        }
        return ""
        
        
    }
    
    func subTitle(row: NSInteger) -> String {
        
        let project = createdProjectList[row]
        
        if let _ = project.subTitle {
            
            return project.subTitle!
        }
        return ""
    }
    
    func projectCreatedDate(row:Int, section:Int)->String{
        
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
    
    func projectCreator(row:Int) -> String{
        
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

    func logout()  {
        
        quickBloxClient.logout()
        createdProjectList.removeAll()
    }
    
    func deleteProjectInParticularRow(row : Int, completion:(Bool, ServerErrorHandling?)->Void) {
        
        let project = self.createdProjectList[row]
        quickBloxClient.deleteProjectWithId(project.projectId!){result,serverError in
            
            if result {
                completion(true,nil)
            }
            else {
                completion(false, serverError)
            }
    }
  }
    
    
    func getProjectMembersList(projectId:String,completion:([PLTeamMember]?, ServerErrorHandling?)->Void) {
        
        var teamMembers:[PLTeamMember] = [PLTeamMember]()
        quickBloxClient.fetchTeamMembersOfProjectId(projectId){ members, serverError in
            
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
                
                  completion(teamMembers, nil)
                
            }
          else
            {
                completion(nil, serverError)
            }
        }
        
    }
    
   
        func uploadUserProfilePicture(image:UIImage,completion:(Bool,ServerErrorHandling?)->Void)
        {
        quickBloxClient.uploadProfilePicture(image){ res, blobId, error in
            
            
                if !res
                {
                    completion(false,error)
                }
                else{
                    completion(true, nil)
              }
        }
   
    }
    
    
    
    func fetchUserProfilePicture(completion:(UIImage?, ServerErrorHandling?)->Void) {
        
      
        
        quickBloxClient.fetchUserProfilePictureWithBlobId() { result,error in
        
        if result != nil {
        
        let image = UIImage(data:result!)
        
        completion(image,nil)
        }
        else { completion(nil, error) }
     
       }
        
    }
    
    
    func updateUserProfilePicture(image:UIImage,completion:(Bool, ServerErrorHandling?)->Void) {
        
     quickBloxClient.updateUserProfilePictureWithBlobId(image) { result, error in
            
            if result {
                
                completion(true, nil)
            }
            else{completion(false, error)
            
            }
        }
     }
    
    func getTodayTasksCount(completion:(String,ServerErrorHandling?)->Void){
        
        quickBloxClient.countOfTodayCommitments(){ count,error in
            
            if count == 0{
                completion(String(0),error)
            }else{
                
                completion(String(count), nil)
            }
         }
     }
    
    func getUpcomingTasksCount(completion:(String, ServerErrorHandling?)->Void){
        
        quickBloxClient.countOfUpComingCommitments()
        { count, error in
            if count == 0{
                completion(String(0), error)
            }else{
                
                completion(String(count), nil)
            }
        }
    }
    
    func getPendingTasksCount(completion:(String, ServerErrorHandling?)->Void){
        
        quickBloxClient.countOfPendingTasks(){ count, error in
            if count == 0{
                completion(String(0), error)
            }else{
                
                completion(String(count), nil)
            }
        }
    }
    
    func getUpcoimgBirthdaysCount(completion:(String,ServerErrorHandling?)-> Void)
    {
        self.getTeamMemberBirthdayListForToday(1) { (count, err) in
            if count != 0
            {
                completion(String(count),nil)
            }
            else
            {
                completion(String(0),err)
            }
        }
    }
    
    
    func getBirthdaysCount(completion:(String, ServerErrorHandling?)->Void){
        
        self.getTeamMemberBirthdayListForToday(0) { (count, err) in
            if count != 0
            {
                completion(String(count),nil)
            }
            else
            {
                completion(String(0),err)
            }
        }
    }
    
    func getTodayAssignmentsCount(completion:(String, ServerErrorHandling?)->Void){
        
        quickBloxClient.countOfTodayAssignments(){ count,error in
            
            if count == 0{
                completion(String(0), error)
            }else{
                completion(String(count), nil)
            }
        }
    }
    
    func getUpcomingAssignmentsCount(completion:(String, ServerErrorHandling?)->Void){
        
        quickBloxClient.countOfUpComingAssignments()
            { count,error in
                if count == 0{
                    completion(String(0), error)
                }else{
                    completion(String(count), nil)
                }
        }
    }
    
    func getPendingAssignmentsCount(completion:(String, ServerErrorHandling?)->Void){
        
        quickBloxClient.countOfPendingAssignments(){ count,error in
            if count == 0{
                completion(String(0), error)
            }else{
                completion(String(count), nil)
            }

        }
    }

    func getTeamMemberBirthdayListForToday(range : Int,completion:(Int,ServerErrorHandling?)-> Void){
        
        self.todayBirthdays.removeAll()
        self.upComingBirthdays.removeAll()
        quickBloxClient.getBirthdayListOfTeamMembers(range){ members,err in
            
            var birthdaysOfMembers = [PLTeamMember]()
           
            if members?.count > 0{
                
                for each in members!{
                    
                    let member = PLTeamMember(name:"", id: 0)
                    member.fullName = each.fields?.objectForKey("name") as! String
                    member.memberEmail = each.fields?.objectForKey("memberEmail") as! String
                    member.memberId = String(each.userID)
                    member.memberUserId = each.fields?.objectForKey("member_User_Id") as! UInt
                    member.profilePicture = each.fields?.objectForKey("avatar") as! String
                    member.birthdayDate = each.fields?.objectForKey("birthday") as! Int
                    birthdaysOfMembers.append(member)
                }
                
                var uniqueArray = [PLTeamMember]()
                let set = NSMutableSet()
                for unique in birthdaysOfMembers
                {
                    let email = unique.memberEmail
                    if !set.containsObject(email)
                    {
                        uniqueArray.append(unique)
                        set.addObject(email)
                    }
                }
                uniqueArray.sortInPlace({ $0.birthdayDate < $1.birthdayDate })
                if range == 0
                {
                    self.todayBirthdays = uniqueArray
 
                }
                else
                {
                    self.upComingBirthdays = uniqueArray
   
                }
                
                completion(uniqueArray.count, nil)
            }
            else
            {
                completion(0, err)
            }
        }
    }

    
}
