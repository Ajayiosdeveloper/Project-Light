//
//  PLQuickbloxHttpClient.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 16/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import Foundation
import Quickblox




class PLQuickbloxHttpClient
{
    //Creating New User Service with Quickblox
    func createNewUserWith(name:String,password:String,completion:(Bool)->Void)
    {
            let user = QBUUser()
            user.login = name
            user.fullName = name
            user.password = password
            user.customData = "Avatar"
            SVProgressHUD.showWithStatus("Signing up")
            QBRequest.signUp(user, successBlock: { (response, retrievedUser) -> Void in
        
            self.initiateUserLogin(name, password:password, completion: {[weak self] (com) -> Void in
                completion(com)
                self!.saveUserCredentialsInDefaults(name,password:password)
            })
                
            })
            { (errorResponse) -> Void in
                    
                  SVProgressHUD.dismiss()
                  completion(false)
            }
    }
    
    //User Login Service with Quickblok
    
    func initiateUserLogin(name:String,password:String,completion:(Bool)->Void){
        
       SVProgressHUD.showWithStatus("Loging in")
       QBRequest.logInWithUserLogin(name, password: password, successBlock: { (response, retrievedUser) -> Void in
        NSUserDefaults.standardUserDefaults().setValue(retrievedUser?.ID, forKey:"USER_ID")
        completion(true)
        SVProgressHUD.dismiss()
        
        }) { (error) -> Void in
          
          completion(false)
          SVProgressHUD.dismiss()
        }
    }
    
    //Saving login credentials to Defaults
    
    func  saveUserCredentialsInDefaults(name:String,password:String){
        NSUserDefaults.standardUserDefaults().setValue(name, forKey:"USER_NAME")
        NSUserDefaults.standardUserDefaults().setValue(password, forKey:"USER_PASSWORD")
    }
    
    //Creating a New Project in QuickBlox
    
    func createNewProjectWith(name:String,description:String,completion:(Bool,String)->Void) {
        
        let customObject = QBCOCustomObject()
        customObject.className = "PLProject"
        customObject.fields?.setValue(name, forKey: "name")
        customObject.fields?.setValue(description, forKey: "description")
        QBRequest.createObject(customObject, successBlock: { (response,object) in
        
            completion(true,object!.ID!)
            
          }) { (response) in
                
                completion(false,"")
        }
    }
    
    
    //Create a New Project with Contributors in QuickBlox
    
    func createNewProjectWithContributors(members:[QBCOCustomObject],completion:(Bool)->Void){
        
          QBRequest.createObjects(members, className:"PLProjectMember", successBlock: { (response, contributors) in
            
                 completion(true)
            
            }) { (response) in
                
                completion(false)
        }
        
        
    }
    
    //Fetching all the Projects of the logged in User
    
    func fetchProjectsOfUserWith(completion:(result:[AnyObject]?)->Void) {
        
        let extendedParameters = NSMutableDictionary()
        
        let userId = QBSession.currentSession().currentUser?.ID
        
        extendedParameters["user_id"] = userId
        
        QBRequest.objectsWithClassName("PLProject", extendedRequest:extendedParameters, successBlock: { (res,objects,page) in
            
               completion(result:objects)
            
            }) { (response) in
                
                
        }
   }
    
    func fetchContributingProjectsOfUser(completion:(result:[AnyObject]?)->Void){
        
        let extendedParameters = NSMutableDictionary()
        
        let userId = QBSession.currentSession().currentUser?.ID
        
        extendedParameters["member_User_Id"] = userId
        
        QBRequest.objectsWithClassName("PLProjectMember", extendedRequest:extendedParameters, successBlock: { (res,objects,page) in
            
            completion(result:objects)
            
        }) { (response) in
            
            
        }
    }
    
    //Perform lagout
    
    func userLogout() {
        
        QBRequest.logOutWithSuccessBlock({ (response) in
            
        }, errorBlock:nil)
    }
    
    //Deleting a Project in the QuickBlox Server
    
    func deleteProjectWithId(projectId:String,completion:(Bool)->Void) {
        
        QBRequest.deleteObjectWithID(projectId, className:"PLProject", successBlock: { (response) in
            
            completion(true)
            
            }) { (response) in
                
              completion(false)
        }
    }
    
    //Getting Users having name
    
    func getListOfUsersWithName(name:String,completion:([QBUUser]?)->Void) {
        
        let generalResponse = QBGeneralResponsePage(currentPage:1, perPage:30)
        
        QBRequest.usersWithFullName(name, page: generalResponse, successBlock: { (response, page,qbUsers) in
            
            if qbUsers?.count > 0{ completion(qbUsers) } else { completion(nil)}
            
            }) { (response) in
                
            }
        }
    
    
    //Fetch Team Members of Project with ProjectId
    
    func fetchTeamMembersOfProjectId(id:String,completion:([QBCOCustomObject]?)->Void) {
        
        let extendedReq = NSMutableDictionary()
        extendedReq.setObject(id, forKey:"_parent_id")
        
        QBRequest.objectsWithClassName("PLProjectMember", extendedRequest: extendedReq, successBlock: { (_, objects, _) in
            
            print("PRAISE THE LORD")
            
            completion(objects)
            
        }) { (res) in
            
            completion(nil)
        }
       

        
    }
    
    
    //Create a Commitment for Project in QuickBlox
    
    func createCommitmentForProject(id:String,date:String,name:String,description:String,completion:(Bool)->Void) {
        
        let customObject = QBCOCustomObject()
        customObject.className = "PLProjectCommitment"
        customObject.fields?.setValue(name, forKey: "name")
        customObject.fields?.setValue(PLSharedManager.manager.projectName, forKey:"projectName")
        customObject.fields?.setValue(description, forKey: "description")
        customObject.fields?.setValue(date, forKey:"targetDate")
        customObject.fields?.setValue(id, forKey:"_parent_id")
        QBRequest.createObject(customObject, successBlock: { (response,object) in
            
            print("PRAISE THE LORD")
            completion(true)
            
            }) { (res) in
                
                completion(false)
                print("Handle error")
        }
}
    
    //Create Assignment for Project in QuickBlox
    
    func createAssignmentForProject(id:String,date:String,name:String,description:String,assignees:[String],assigneeUserIds:[UInt],completion:(Bool)->Void) {
        
        let customObject = QBCOCustomObject()
        customObject.className = "PLProjectAssignment"
        customObject.fields?.setObject(PLSharedManager.manager.projectName, forKey: "projectName")
        customObject.fields?.setValue(name, forKey: "name")
        customObject.fields?.setValue(description, forKey: "description")
        customObject.fields?.setValue(date, forKey:"targetDate")
        customObject.fields?.setValue(assignees, forKey: "assignees")
        customObject.fields?.setValue(assigneeUserIds, forKey: "assigneeUserId")
        customObject.fields?.setValue(id, forKey:"_parent_id")
        
        QBRequest.createObject(customObject, successBlock: { (res,object) in
            
            print("PRAISE THE LORD")
            
            completion(true)
            
            }) { (res) in
                
                completion(false)
        }
    }
    
    //Fetching Commitments for Project
    
    func fetchCommitmentsForProject(id:String,completion:(Bool,[QBCOCustomObject]?)->Void)
    {
        let extendedReq = NSMutableDictionary()
        
        extendedReq.setValue(id, forKey:"_parent_id")
        
        QBRequest.objectsWithClassName("PLProjectCommitment", extendedRequest: extendedReq, successBlock: { (res, commitments, page) in
            
            
            print("PRAISE THE LORD")
            
            completion(true,commitments)
            
            }) { (res) in
             
                print("handle error")
                
                completion(false,nil)
        }
        
    }
   //Fetching Assignments for Project
    
    func fetchAssignmentsForProject(id:String,completion:(Bool,[QBCOCustomObject]?)->Void) {
        
        let extendedReq = NSMutableDictionary()
        
        extendedReq.setValue(id, forKey:"_parent_id")
        
        QBRequest.objectsWithClassName("PLProjectAssignment", extendedRequest: extendedReq, successBlock: { (res, assignments, page) in
            
            print("PRAISE THE LORD")
            
            completion(true,assignments)
            
        }) { (res) in
        
            print("handle error")
            
            completion(false,nil)
        }
        
    }
    
    
    func uploadProfilePicture(image:UIImage,completion:(Bool,UInt?)->Void){
        
        let imageData = UIImagePNGRepresentation(image)
        
        let avatarUnique = QBSession.currentSession().currentUser?.ID
        
        QBRequest.TUploadFile(imageData!, fileName: "MYAVATAR\(avatarUnique!)", contentType: "image/png", isPublic: true, successBlock: {[weak self] (_, blob) in
            
            self!.updateUserParamenterForAvatar(blob.ID)
            
            completion(true,blob.ID)
            
            }, statusBlock: { (_, _) in
                
                
            }) { (_) in
                
               completion(false,nil)
        }
    }
    
    func fetchUserAvatarWithBlobId(completion:(NSData?)->Void)
    {
        QBRequest.blobsWithSuccessBlock({ (_, _, blobs) in
            
            if let _ = blobs {
                
            let avatarUnique = QBSession.currentSession().currentUser?.ID
              
              for blob in blobs!
              {
                
                if blob.name == "MYAVATAR\(avatarUnique!)"
                {
                    
                    QBRequest.downloadFileWithID(blob.ID, successBlock: { (_, imageData) in
                        
                        completion(imageData)
                        
                        }, statusBlock: { (_, _) in
                            
                        }, errorBlock: { (_) in
                            
                         completion(nil)
                    })
                    
                }
            }
            
            } else { completion(nil)}
            
        }) { (_) in
                
            
        }
        
    
    }
    
    
    func updateUserAvatarWithBlobId(image:UIImage,completion:(Bool)->Void){
        
        QBRequest.blobsWithSuccessBlock({ (_, _, blobs) in
        
            if let _ = blobs {
                
                if blobs?.count == 0
                {
                    
                    self.uploadProfilePicture(image, completion: { (res, _) in
                        
                        if res {
                            
                            completion(true)
                        }
                            
                        else{ completion(false)}
                        
                    })
                }
                else{
                
                let avatarUnique = QBSession.currentSession().currentUser?.ID
                
                for blob in blobs!
                {
                    
                    if blob.name == "MYAVATAR\(avatarUnique!)"
                    {
                        let imageData = UIImageJPEGRepresentation(image, 0.1)
                        
                       self.updateUserParamenterForAvatar(blob.ID)
                        
                       QBRequest.TUpdateFileWithData(imageData, file: blob, successBlock: { (res) in
                        
                        
                        
                           completion(true)
                        
                        }, statusBlock: { (_, _) in
                            
                        }, errorBlock: { (_) in
                            
                            completion(false)
                       })
                        
                    }
                  }
                }
            }
            
        }) { (_) in
        
        }
    }
    
    func updateUserParamenterForAvatar(withBlobId:UInt)
    {
        let customString = String(withBlobId)
        let updateUser = QBUpdateUserParameters()
        updateUser.customData = customString
        QBRequest.updateCurrentUser(updateUser, successBlock: { (_, _) in
            
            print(QBSession.currentSession().currentUser?.customData)
            
            }, errorBlock: nil)
    }
    
    
    func downloadTeamMemberAvatar(avatarFileId:String,completion:(UIImage?)->Void){
        
        let id = UInt(avatarFileId)
        
        if let _ = id{
        
        QBRequest.downloadFileWithID(id!, successBlock: { (_, imageData) in
            
            let image = UIImage(data:imageData)
            
             completion(image)
            
            }, statusBlock: { (_, _) in
                
            }, errorBlock: { (_) in
                
                completion(nil)
        })
            
        }else{completion(nil)}
        
    }
    
    
    func fetchUserAssignmentsForProject(userId:UInt,projectId:String,completion:([PLAssignment]?)->Void)
    {
        
        let extended = NSMutableDictionary()
        
        extended.setObject(userId, forKey:"assigneeUserId[or]")
        extended.setObject(projectId, forKey:"_parent_id")
        
        QBRequest.objectsWithClassName("PLProjectAssignment", extendedRequest:extended, successBlock: { (res,objects, _) in
            print("PRAISE THE LORD")
            
            var assigmnents = [PLAssignment]()
            
            if let _ = objects{
                
                for assignment in objects!{
                    
                    let plAssignment = PLAssignment()
                    plAssignment.name = assignment.fields?.objectForKey("name") as! String
                    plAssignment.details = assignment.fields?.objectForKey("description") as! String
                    plAssignment.targetDate = assignment.fields?.objectForKey("targetDate") as! String
                    plAssignment.assineesUserIds = assignment.fields?.objectForKey("assigneeUserId") as! [UInt]
                    assigmnents.append(plAssignment)
                }
                
                completion(assigmnents)
            }else {completion(nil)}
            
            }) { (err) in
            
            print("error")
                
                completion(nil)
        }
    }
    
    
    
}