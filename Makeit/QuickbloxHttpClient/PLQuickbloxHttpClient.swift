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
    func createNewUserWith(name:String,password:String,email:String,completion:(Bool, ServerErrorHandling?)->Void)
    {
        let user = QBUUser()
        user.login = name
        user.fullName = name
        user.password = password
        user.email = email
        user.customData = "Avatar"
        user.phone = "000000"
        SVProgressHUD.showWithStatus("Signing up")
        
        QBRequest.signUp(user, successBlock: { (response, retrievedUser) -> Void in
            
            self.initiateUserLogin(name, password:password, completion: {[weak self] (com,error) -> Void in
                completion(com, nil)
                self!.saveUserCredentialsInDefaults(name,password:password)
                })
            
            })
        {(errorResponse) -> Void in
            
            SVProgressHUD.dismiss()
            
             completion(false,self.handleErrors(errorResponse))
       }
    }
    
    func handleErrors(errorCode: QBResponse) -> ServerErrorHandling
    {
        switch errorCode.status {
        case .BadRequest:
           return ServerErrorHandling.BadRequest
        case .ServerError:
           return ServerErrorHandling.ServerError
        case .ValidationFailed:
          return ServerErrorHandling.StatusCodeValidationFailed
        case .UnAuthorized:
          return ServerErrorHandling.UnAuthorized
        default : return ServerErrorHandling.Other
        }
    }
    
    //User Login Service with Quickblok
    
    func initiateUserLogin(name:String,password:String,completion:(Bool,ServerErrorHandling?)->Void){
        
        SVProgressHUD.showWithStatus("Logging in")
        QBRequest.logInWithUserLogin(name, password: password, successBlock: { (response, retrievedUser) -> Void in
            NSUserDefaults.standardUserDefaults().setValue(retrievedUser?.ID, forKey:"USER_ID")
            PLSharedManager.manager.userName = name
            PLSharedManager.manager.userPassword = password
            PLSharedManager.manager.loggedInUserId = (retrievedUser?.ID)!
            self.registerForAPNS()
            completion(true,nil)
            SVProgressHUD.dismiss()
            
        }) { (error) -> Void in
            
            completion(false,self.handleErrors(error))
            SVProgressHUD.dismiss()
        }
    }
    
    func registerForAPNS()
    {
            
            let application = UIApplication.sharedApplication()
            
            if #available(iOS 8.0, *) {
                let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
                let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
                
                application.registerUserNotificationSettings(pushNotificationSettings)
                application.registerForRemoteNotifications()
            }else{
            
                let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
                application.registerForRemoteNotificationTypes(types)
            }
       
    }
    //Saving login credentials to Defaults
    
    func  saveUserCredentialsInDefaults(name:String,password:String){
        NSUserDefaults.standardUserDefaults().setValue(name, forKey:"USER_NAME")
        NSUserDefaults.standardUserDefaults().setValue(password, forKey:"USER_PASSWORD")
    }
    
    //Creating a New Project in QuickBlox
    
    func createNewProjectWith(name:String,description:String,completion:(Bool,String,ServerErrorHandling?)->Void) {
        
        let customObject = QBCOCustomObject()
        customObject.className = "PLProject"
        customObject.fields?.setValue(name, forKey: "name")
        customObject.fields?.setValue(description, forKey: "description")
        customObject.fields?.setValue(PLSharedManager.manager.userName, forKey: "projectCreatorName")
        QBRequest.createObject(customObject, successBlock: { (response,object) in
            
            completion(true,object!.ID!,nil)
            
        }) { (response) in
            
            completion(false,"",self.handleErrors(response))
        }
    }
    
    
    //Create a New Project with Contributors in QuickBlox
    
    func createNewProjectWithContributors(members:[QBCOCustomObject],completion:(Bool,ServerErrorHandling?)->Void){
        
        QBRequest.createObjects(members, className:"PLProjectMember", successBlock: { (response, contributors) in
            
             completion(true,nil)
            
        }) { (response) in
        
            completion(false,self.handleErrors(response))
        }
        
        
    }
    
    //Fetching all the Projects of the logged in User
    
    func fetchProjectsOfUserWith(completion:(result:[AnyObject]?,ServerErrorHandling?)->Void) {
        
        let extendedParameters = NSMutableDictionary()
        
        let userId = QBSession.currentSession().currentUser?.ID
        
        extendedParameters["user_id"] = userId
        
        QBRequest.objectsWithClassName("PLProject", extendedRequest:extendedParameters, successBlock: { (res,objects,page) in
            
            completion(result:objects,nil)
            
        }) { (response) in
            
            completion(result: nil,self.handleErrors(response))
        }
    }
    
    func fetchContributingProjectsOfUser(completion:(result:[AnyObject]?,ServerErrorHandling?)->Void){
        
        let extendedParameters = NSMutableDictionary()
        
        let userId = QBSession.currentSession().currentUser?.ID
        
        extendedParameters["member_User_Id"] = userId
        
        QBRequest.objectsWithClassName("PLProjectMember", extendedRequest:extendedParameters, successBlock: { (res,objects,page) in
            
            completion(result:objects,nil)
            
        }) { (response) in
            
            completion(result: nil,self.handleErrors(response))
        }
    }
    
    //Perform logout
    
    func logout() {
        
        QBRequest.logOutWithSuccessBlock({ (response) in
            
            }, errorBlock:nil)
    }
    
    //Deleting a Project in the QuickBlox Server
    
    func deleteProjectWithId(projectId:String,completion:(Bool,ServerErrorHandling?)->Void) {
        
        QBRequest.deleteObjectWithID(projectId, className:"PLProject", successBlock: { (response) in
            
            completion(true,nil)
            
        }) { (response) in
            
            completion(false,self.handleErrors(response))
        }
    }
    
    //Getting Users having name
    
    func getListOfUsersWithName(name:String,completion:([QBUUser]?,ServerErrorHandling?)->Void) {
        
        let generalResponse = QBGeneralResponsePage(currentPage:1, perPage:30)
        
        QBRequest.usersWithFullName(name, page: generalResponse, successBlock: { (response, page,qbUsers) in
            
            if qbUsers?.count > 0
            {
                completion(qbUsers,nil)
            }
            else { completion(nil,nil) }
            
        }) { (response) in
            completion(nil,self.handleErrors(response))
        }
    }
    
    
    //Fetch Team Members of Project with ProjectId
    
    func fetchTeamMembersOfProjectId(id:String,completion:([QBCOCustomObject]?,ServerErrorHandling?)->Void) {
        
        let extendedReq = NSMutableDictionary()
        extendedReq.setObject(id, forKey:"_parent_id")
        
        QBRequest.objectsWithClassName("PLProjectMember", extendedRequest: extendedReq, successBlock: { (_, objects, _) in
                completion(objects,nil)
            
        }) { (res) in
            
            completion(nil,self.handleErrors(res))
        }
   }
    
    //Create a Commitment for Project in QuickBlox
    
    func createCommitmentForProject(id:String,startDate : Int, targetDate:Int, name:String, description:String, startTime : String, endTime: String,identifier:String, completion:(Bool,ServerErrorHandling?)->Void) {
        
        let customObject = QBCOCustomObject()
        customObject.className = "PLProjectCommitment"
        customObject.fields?.setValue(name, forKey: "name")
        customObject.fields?.setValue(PLSharedManager.manager.projectName, forKey:"projectName")
        customObject.fields?.setValue(description, forKey: "description")
        customObject.fields?.setValue(startDate, forKey:"startDate")
        customObject.fields?.setValue(targetDate, forKey:"targetDate")
        customObject.fields?.setValue(startTime, forKey: "startTime")
        customObject.fields?.setValue(endTime, forKey: "endTime")
        customObject.fields?.setValue(0, forKey: "isCompleted")
        customObject.fields?.setValue(id, forKey:"_parent_id")
        if identifier == ""{
            
            customObject.fields?.setValue("NULL", forKey: "calendarIdentifier")
            
        }else{
            
            customObject.fields?.setValue(identifier, forKey: "calendarIdentifier")
        }
        
        
        QBRequest.createObject(customObject, successBlock: { (response,object) in
            
            completion(true,nil)
            
        }) { (res) in
            
            completion(false,self.handleErrors(res))
        
        }
    }
    
    func updateCommitmentTask(commitment:PLCommitment,completion:(Bool,ServerErrorHandling?)->Void)
    {
        let startTime = self.timeFormats(commitment.startDate)
        let endTime = self.timeFormats(commitment.targetDate)
    
        let startInterval = self.convertdateToTimeinterval(stringToDate(commitment.startDate), dateFormat: "dd-MM-yyyy")
        let endInterval = self.convertdateToTimeinterval(stringToDate(commitment.targetDate),  dateFormat: "dd-MM-yyyy")

            let updateObject = QBCOCustomObject()
            updateObject.className = "PLProjectCommitment"
            updateObject.ID = commitment.commitmentId
            updateObject.fields?.setObject(commitment.name, forKey: "name")
            updateObject.fields?.setObject(commitment.details, forKey: "description")
            updateObject.parentID = commitment.projectId
            updateObject.fields?.setObject(startTime, forKey: "startTime")
            updateObject.fields?.setObject(endTime, forKey: "endTime")
            updateObject.fields?.setObject(startInterval, forKey: "startDate")
            updateObject.fields?.setObject(endInterval, forKey: "targetDate")
            updateObject.fields?.setObject(commitment.isCompleted, forKey: "isCompleted")
            QBRequest.updateObject(updateObject, successBlock: { (respinse, object) in
                
                completion(true,nil)
           })
            { (res) in
                completion(false,self.handleErrors(res))
                   
        }
    }
    
    //Create Assignment for Project in QuickBlox
    
    func createAssignmentForProject(id:String,startDate: Int, targetDate:Int, name:String,description:String,assignees:[String],assigneeUserIds:[UInt],startTime : String, endTime: String,members:[PLTeamMember], completion:(Bool,ServerErrorHandling?)->Void) {
        
        let customObject = QBCOCustomObject()
        customObject.className = "PLProjectAssignment"
        customObject.fields?.setObject(PLSharedManager.manager.projectName, forKey: "projectName")
        customObject.fields?.setValue(name, forKey: "name")
        customObject.fields?.setValue(description, forKey: "description")
        customObject.fields?.setValue(targetDate, forKey:"targetDate")
        customObject.fields?.setValue(startDate, forKey:"startDate")
        customObject.fields?.setValue(startTime, forKey: "startTime")
        customObject.fields?.setValue(endTime, forKey: "endTime")
        customObject.fields?.setValue(assignees, forKey: "assignees")
        customObject.fields?.setValue(assigneeUserIds, forKey: "assigneeUserId")
        customObject.fields?.setValue(0, forKey: "status")
        customObject.fields?.setValue(0, forKey: "percentageCompleted")
        customObject.fields?.setValue(id, forKey:"_parent_id")
        var assigneeStatus:[String] = [String]()
        for status in assigneeUserIds{
            assigneeStatus += [String(status) + "@@@0"]
        }
        customObject.fields?.setValue(assigneeStatus, forKey: "assigneeStatus")
        
      QBRequest.createObject(customObject, successBlock: { (res,object) in
            
            for each in members{
             let customObjectTwo = QBCOCustomObject()
             customObjectTwo.className = "PLProjectAssignmentMember"
             customObjectTwo.fields?.setValue(each.fullName, forKey: "assigneeName")
             customObjectTwo.fields?.setValue(each.memberUserId, forKey: "assigneeUserId")
             customObjectTwo.fields?.setValue(each.memberEmail, forKey: "assigneeEmail")
             customObjectTwo.fields?.setValue(0, forKey: "assigneeStatus")
             customObjectTwo.fields?.setValue(each.profilePicture, forKey: "Avatar")
             customObjectTwo.fields?.setValue(0, forKey: "percentageCompleted")
             customObjectTwo.fields?.setValue(PLSharedManager.manager.projectName, forKey: "projectName")
             customObjectTwo.fields?.setValue(object?.ID!, forKey:"_parent_id")
            
                
             QBRequest.createObject(customObjectTwo, successBlock: { (_, _) in
               
                PLProjectNotification.sendAssignmentNotificationToAssignees(UInt(each.memberUserId),assignmentName:name,projectName: PLSharedManager.manager.projectName,memberName: each.fullName)

                 completion(true, nil)
                
                }, errorBlock: { (res) in
                    completion(false, self.handleErrors(res))
             })
        }
        
            
            completion(true,nil)
            
        }) { (res) in
            
            completion(false,self.handleErrors(res))
        }
    }
    
    //Fetching Commitments for Project
    
    func fetchCommitmentsForProject(id:String,completion:(Bool,[QBCOCustomObject]?,ServerErrorHandling?)->Void)
    {
        let extendedReq = NSMutableDictionary()
        
        extendedReq.setValue(id, forKey:"_parent_id")
        
        QBRequest.objectsWithClassName("PLProjectCommitment", extendedRequest: extendedReq, successBlock: { (res, commitments, page) in
            
                completion(true,commitments,nil)
            
        }) { (res) in
            
           completion(false,nil,self.handleErrors(res))
        }
        
    }
    //Fetching Assignments for Project
    
    func fetchAssignmentsForProject(id:String,isCreator:Bool,completion:(Bool,[QBCOCustomObject]?,ServerErrorHandling?)->Void) {
        
        let extendedReq = NSMutableDictionary()
        
        extendedReq.setValue(id, forKey:"_parent_id")
        
        if !isCreator{
       
        let userId = QBSession.currentSession().currentUser?.ID
        extendedReq.setObject(userId!, forKey:"assigneeUserId[or]")
        
        }
        
        QBRequest.objectsWithClassName("PLProjectAssignment", extendedRequest: extendedReq, successBlock: { (res, assignments, page) in
        
            
            completion(true,assignments,nil)
            
        }) { (res) in
            
            completion(false,nil,self.handleErrors(res))
        }
        
    }
    
    
    func uploadProfilePicture(image:UIImage,completion:(Bool,UInt?,ServerErrorHandling?)->Void){
        
        let imageData = UIImagePNGRepresentation(image)
        
        let avatarUnique = QBSession.currentSession().currentUser?.ID
        
        QBRequest.TUploadFile(imageData!, fileName: "MYAVATAR\(avatarUnique!)", contentType: "image/png", isPublic: true, successBlock: {[weak self] (_, blob) in
            
            self!.updateUserParamenterForAvatar(blob.ID)
            
            completion(true,blob.ID,nil)
            
            }, statusBlock: { (_, _) in
                
                
        }) { (res) in
            
            completion(false, nil, self.handleErrors(res))
        }
    }
    
    func fetchUserProfilePictureWithBlobId(completion:(NSData?, ServerErrorHandling?) -> Void)
    {
        QBRequest.blobsWithSuccessBlock({ (_, _, blobs) in
            
            if let _ = blobs {
                
                let avatarUnique = QBSession.currentSession().currentUser?.ID
                
                for blob in blobs!
                {
                    
                    if blob.name == "MYAVATAR\(avatarUnique!)"
                    {
                        
                        QBRequest.downloadFileWithID(blob.ID, successBlock: { (_, imageData) in
                            
                            completion(imageData,nil)
                            
                            }, statusBlock: { (_, _) in
                                
                            }, errorBlock: { (res) in
                                
                                completion(nil,self.handleErrors(res))
                        })
                        
                    }
                }
                
            } else { completion(nil,nil)}
            
        }) { (res) in
            
             completion(nil,self.handleErrors(res))
        }
        
        
    }
    
    
    func updateUserProfilePictureWithBlobId(image:UIImage,completion:(Bool,ServerErrorHandling?)->Void){
        
        QBRequest.blobsWithSuccessBlock({ (_, _, blobs) in
            
            if let _ = blobs {
                
                if blobs?.count == 0
                {
                    
                    self.uploadProfilePicture(image, completion: { (res, _,error) in
                        
                        if res {
                           
                            self.updateUserParamenterForAvatar(1234)
                            
                            completion(true,nil)
                        }
                            
                        else{ completion(false,nil)}
                        
                    })
                }
                else{
                    
                    let avatarUnique = QBSession.currentSession().currentUser?.ID
                    
                    for blob in blobs!
                    {
                        
                        if blob.name == "MYAVATAR\(avatarUnique!)"
                        {
                            let imageData = UIImageJPEGRepresentation(image, 1)
                            
                            self.updateUserParamenterForAvatar(blob.ID)
                            
                            QBRequest.TUpdateFileWithData(imageData, file: blob, successBlock: { (res) in
                                
                            completion(true,nil)
                                
                                }, statusBlock: { (_, _) in
                                    
                                }, errorBlock: { (res) in
                                    
                                    completion(false, self.handleErrors(res))
                            })
                        }
                    }
                }
            }
            
        }) { (res) in
           completion(false, self.handleErrors(res))
        }
    }
    
    func updateUserParamenterForAvatar(withBlobId:UInt)
    {
        let customString = String(withBlobId)
        let updateUser = QBUpdateUserParameters()
        updateUser.customData = customString
        updateUser.blobID = Int(withBlobId)
        QBRequest.updateCurrentUser(updateUser, successBlock: { (_, _) in
            
            print(QBSession.currentSession().currentUser?.customData)
            
            }, errorBlock: nil)
    }
    
    
    func downloadTeamMemberAvatar(avatarFileId:String,completion:(UIImage?,ServerErrorHandling?)->Void){
        
        let id = UInt(avatarFileId)
        
        if let _ = id{
            
            QBRequest.downloadFileWithID(id!, successBlock: { (_, imageData) in
                
                let image = UIImage(data:imageData)
                
                completion(image,nil)
                
                }, statusBlock: { (_, _) in
                    
                }, errorBlock: { (res) in
                    
                    completion(nil,self.handleErrors(res))
            })
            
        }else
        {
            completion(nil,nil)
        }
        
    }
    
    
    func fetchUserAssignmentsForProject(userId:UInt,projectId:String,completion:([PLAssignment]?,ServerErrorHandling?)->Void)
    {
        
        let extended = NSMutableDictionary()
        
        extended.setObject(userId, forKey:"assigneeUserId[or]")
        extended.setObject(projectId, forKey:"_parent_id")

        QBRequest.objectsWithClassName("PLProjectAssignment", extendedRequest:extended, successBlock: { (res,objects, _) in
            
            var assigmnents = [PLAssignment]()
            
            if let _ = objects{
                
                for assignment in objects!{
                    
                    let plAssignment = PLAssignment()
                    plAssignment.name = assignment.fields?.objectForKey("name") as! String
                    plAssignment.details = assignment.fields?.objectForKey("description") as! String
                    let endInterval = assignment.fields?.objectForKey("targetDate") as! NSTimeInterval
                    let startInterval = assignment.fields?.objectForKey("startDate") as! NSTimeInterval
                    let endTime = assignment.fields?.objectForKey("endTime") as! String
                    let startTime = assignment.fields?.objectForKey("startTime") as! String

                    plAssignment.startDate = self.dateFormat(startInterval)
                    plAssignment.targetDate = self.dateFormat(endInterval)
                    
                    plAssignment.startDate += " \(startTime)"
                    plAssignment.targetDate += " \(endTime)"
                  
                    plAssignment.assineesUserIds = assignment.fields?.objectForKey("assigneeUserId") as! [UInt]
                    assigmnents.append(plAssignment)
                }
                
                completion(assigmnents,nil)
            }else {completion(nil,nil)}
            
        }) { (err) in
            
            print("error")
            
            completion(nil,self.handleErrors(err))
        }
   }
    
    //Creating a Chat Group for a Project
    
    func createChatGroupWitTeamMembers(name :String,  projectId:String,membersIds:[UInt],completion:(Bool,PLChatGroup?,ServerErrorHandling?)->Void)
    {
        
        let chatDialog = QBChatDialog(dialogID: nil, type: QBChatDialogType.Group)
        chatDialog.name = "\(name) \(projectId)"
        chatDialog.occupantIDs = membersIds
        QBRequest.createDialog(chatDialog, successBlock: { (response: QBResponse?, createdDialog : QBChatDialog?) -> Void in
            
            let chatGroup = PLChatGroup()
            chatGroup.name = name
            chatGroup.opponents = (createdDialog?.occupantIDs)! as! [UInt]
            chatGroup.chatGroupId = (createdDialog?.roomJID)!
            chatGroup.unReadMessageCount = 0
            completion(true,chatGroup,nil)
            
        }) { (res) -> Void in
         completion(false,nil,self.handleErrors(res))
        }
    }
    
    
    func createChatNotificationForGroupChatCreation(dialog: QBChatDialog) -> QBChatMessage {
        let inviteMessage: QBChatMessage = QBChatMessage()
        let customParams: NSMutableDictionary = NSMutableDictionary()
        customParams["xmpp_room_jid"] = dialog.roomJID
        customParams["name"] = dialog.name
        customParams["_id"] = dialog.ID
        customParams["type"] = dialog.type.rawValue
        var recipientsString = ""
        for each in dialog.occupantIDs!{
           
            recipientsString = String(each)
            recipientsString += ","
        }
        customParams["occupants_ids"] = recipientsString//", ".join(dialog.occupantIDs as! [String])
        customParams["notification_type"] = "1"
        inviteMessage.customParameters = customParams
        return inviteMessage
    }
    
    
    func fetchChatGroupsForProject(completion:(Bool,[PLChatGroup],ServerErrorHandling?)->Void){
        
        let searchString = PLSharedManager.manager.projectId
        
        let extendedRequest = ["name[ctn]" : searchString]
        
        let page = QBResponsePage(limit: 20, skip: 0)
        
        QBRequest.dialogsForPage(page, extendedRequest:extendedRequest, successBlock: {[weak self] (response: QBResponse, dialogs: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, page: QBResponsePage?) -> Void in
            
            var chatGroups:[PLChatGroup] = [PLChatGroup]()
            
            if let _ = dialogs{
                
                for eachGroup in dialogs!{
                    
                    var chatGroup =  PLChatGroup()
                    chatGroup.name = self!.removeProjectIdFromChatGroupName((eachGroup.name)!)
                    chatGroup.chatGroupId = (eachGroup.ID)!
                    chatGroup.lastMessage = eachGroup.lastMessageText
                    chatGroup.unReadMessageCount = eachGroup.unreadMessagesCount
                    if let _ = eachGroup.lastMessageDate{
                        chatGroup.lastMessageDate = NSDateFormatter.localizedStringFromDate(eachGroup.lastMessageDate!, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                    }
                    chatGroup.opponents = eachGroup.occupantIDs! as! [UInt]
                    chatGroups.append(chatGroup)
                }
            }
            
            completion(true,chatGroups,nil)
            
        }) { (response) -> Void in
            completion(false,[],self.handleErrors(response))
        }
        
    }
    
    func getMessagesFromChatGroup(groupId:String,completion:(Bool,[JSQMessage]?,ServerErrorHandling?)->Void){
        
        let page = QBResponsePage(limit: 100, skip: 0)
        
       
        
        QBRequest.messagesWithDialogID(groupId, extendedRequest:nil, forPage:page, successBlock: { (_, messages, _) in
            
            var chatMessages = [JSQMessage]()
            
            if let _ = messages{
                
                
                
                for message in messages!{
                    
                    let messgaeSenderId = message.customParameters!["messageSenderId"] as! String
                    
                    if message.attachments?.count > 0{
                        let attachmentDict = message.attachments?.first
                        let fileId = attachmentDict?.ID
                        QBRequest.downloadFileWithID(UInt(fileId!)!, successBlock: { (_, imageData) in
                            let imageUI = UIImage(data:imageData)
                            let messageWithSender = message.customParameters!["name"] as! String
                            
                            let attachedImage = JSQPhotoMediaItem(image:imageUI)
                            let eachMessage = JSQMessage(senderId:messgaeSenderId, senderDisplayName:messageWithSender, date: message.dateSent!, media:attachedImage)
                            chatMessages.append(eachMessage)
                            completion(true,chatMessages,nil)
                            
                            }, statusBlock: { (_, _) in
                                
                            }, errorBlock: { (res) in
                                completion(false,nil,self.handleErrors(res))
                        })
                    }
                    else{
                        
                        let messageWithSender = message.customParameters!["name"] as! String
                        
                       
                       
                        let eachMessage = JSQMessage(senderId:messgaeSenderId, senderDisplayName:messageWithSender, date:message.dateSent!, text: message.text!)
                        chatMessages.append(eachMessage)
                    }
                    
                }
                
                print(chatMessages.count)
                
                
            }
            
            completion(true,chatMessages,nil)
            
            }, errorBlock:{(res)in
                
                completion(false,nil,self.handleErrors(res))
                
        })
        
    }
    
    func sendMessageWithoutAttachment(text:String,group:QBChatDialog,completion:(Bool)->Void){
        
        let message: QBChatMessage = QBChatMessage()
        message.text = text
        let params = NSMutableDictionary()
        params["save_to_history"] = true
        params["name"] = QBSession.currentSession().currentUser?.fullName!
        params["messageSenderId"] = String(QBSession.currentSession().currentUser!.ID)
        message.customParameters = params
        message.deliveredIDs = [(QBSession.currentSession().currentUser?.ID)!]
        message.readIDs = [(QBSession.currentSession().currentUser?.ID)!]
        message.markable = true
        group.sendMessage(message, completionBlock: { (error) -> Void in
            
            if error == nil{
            
                completion(true)
            }
        })
        
    }
    
    
    func sendMessageWithAttachment(imageData:NSData,text:String,group:QBChatDialog,completion:(Bool,ServerErrorHandling?)->Void){
        
        QBRequest.TUploadFile(imageData, fileName: "image.png", contentType: "image/png", isPublic: false, successBlock: {(response: QBResponse!, uploadedBlob: QBCBlob!) in
            // Create and configure message
            let message: QBChatMessage = QBChatMessage()
            message.text = text
            let params = NSMutableDictionary()
            params["save_to_history"] = true
            params["name"] = QBSession.currentSession().currentUser?.fullName!
            params["messageSenderId"] = String(QBSession.currentSession().currentUser!.ID)
            message.customParameters = params
            message.deliveredIDs = [(QBSession.currentSession().currentUser?.ID)!]
            message.readIDs = [(QBSession.currentSession().currentUser?.ID)!]
            message.markable = true
            let uploadedFileID: UInt = uploadedBlob.ID
            let attachment: QBChatAttachment = QBChatAttachment()
            attachment.type = "image"
            attachment.ID = String(uploadedFileID)
            message.attachments = [attachment]
            // Send message
            
            group.sendMessage(message, completionBlock: { (error: NSError?) -> Void in
                
                if error == nil{
                    completion(true, nil)
                }
            })
            
            }, statusBlock: {(request: QBRequest?, status: QBRequestStatus?) in
                
            }, errorBlock: {(response: QBResponse!) in
                
                completion(false, self.handleErrors(response))
                
        })
    }
    
    
    func removeProjectIdFromChatGroupName(chatGroupName:String)->String{
        
        var namesInStrings = chatGroupName.componentsSeparatedByString(" ")
        namesInStrings.removeLast()
        var finalName = ""
        for x in namesInStrings{
            
            finalName += x
            finalName += " "
        }
        return finalName
    }
    
    
    func updateProfileOfAnUser(dateOfBirth:String?, companyName:String?, technology:String?, experience:String?, designation: String?,emailId : String?, completion:(Bool,ServerErrorHandling?)->Void)
    {
        
        let userId = QBSession.currentSession().currentUser?.ID
        
        let customObject = QBCOCustomObject()
        customObject.className = "UserInfo"
        customObject.fields?.setValue(dateOfBirth, forKey: "dateOfBirth")
        customObject.fields?.setValue(companyName, forKey: "companyName")
        customObject.fields?.setValue(technology, forKey: "technology")
        customObject.fields?.setValue(experience, forKey: "experience")
        customObject.fields?.setValue(designation, forKey: "designation")
        customObject.fields?.setValue(emailId, forKey: "emailId")
        customObject.fields?.setValue(userId, forKey: "_parent_id")
        let params = NSMutableDictionary()
        params.setValue(userId!, forKey:"_parent_id")
        QBRequest.objectsWithClassName("UserInfo", extendedRequest: params, successBlock: { (_,objects, _) in
            
            if objects?.count == 0
            {
                QBRequest.createObject(customObject, successBlock: { (response, object) in
                    print(object?.fields?.objectForKey("companyName"))
                    completion(true,nil)
                    })
                { (respons) in
                    completion(false,self.handleErrors(respons))
                }
            }
            else
            {
                let objectToUpdate = objects!.first
                
                objectToUpdate!.fields?.setValue(dateOfBirth, forKey: "dateOfBirth")
                objectToUpdate!.fields?.setValue(companyName, forKey: "companyName")
                objectToUpdate!.fields?.setValue(technology, forKey: "technology")
                objectToUpdate!.fields?.setValue(experience, forKey: "experience")
                objectToUpdate!.fields?.setValue(designation, forKey: "designation")
                objectToUpdate!.fields?.setValue(emailId, forKey: "emailId")
                QBRequest.updateObject(objectToUpdate!, successBlock: { (response, objc) in
                    completion(true,nil)
                    
                }) { (res) in
                    completion(false,self.handleErrors(res))
                }
                
            }
            
        }) { (_) in
            
            print("Error")
        }
    }
    
    
    func getUserProfileDetails(userId : UInt, completion:([String:AnyObject]?,ServerErrorHandling?)->Void)
    {
        let params = NSMutableDictionary()
        params.setValue(userId, forKey:"_parent_id")
        QBRequest.objectsWithClassName("UserInfo", extendedRequest: params, successBlock: { (_,objects, _) in
            
            if objects?.count == 0
            {
                completion(nil,nil)
            }
            else
            {
                let objectToUpdate = objects!.first
                
                var infoDict = [String:AnyObject]()
                infoDict["dateOfBirth"] = objectToUpdate?.fields?.valueForKey("dateOfBirth")
                infoDict["experience"] = objectToUpdate?.fields?.valueForKey("experience")
                infoDict["companyName"] = objectToUpdate?.fields?.valueForKey("companyName")
                infoDict["technology"] = objectToUpdate?.fields?.valueForKey("technology")
                infoDict["designation"] = objectToUpdate?.fields?.valueForKey("designation")
                infoDict["emailId"] = objectToUpdate?.fields?.valueForKey("emailId")
                completion(infoDict,nil)
            }
            
        }) { (res) in
            completion(nil,self.handleErrors(res))
    
        }
    }
    
    func sendforgotPasswordLinkToEmail(email : String,completion:(ServerErrorHandling?)->Void)
    {
        QBRequest.resetUserPasswordWithEmail(email, successBlock: { (response) in
            
            completion(nil)
            
        }) { (err) in
           
           completion(self.handleErrors(err))
        
        }
        
    }
    
    
    
    func countOfTodayCommitments(completion:(UInt,ServerErrorHandling?)->Void){
        
    let extendedReq = NSMutableDictionary()
        
        
        let timeInterval = Int(convertdateToTimeinterval(NSDate(),dateFormat: "dd-MM-yyyy"))
        extendedReq.setValue(timeInterval, forKey: "startDate")
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "user_id")
        QBRequest.countObjectsWithClassName("PLProjectCommitment", extendedRequest: extendedReq, successBlock: { (res, count) in
            completion(count,nil)
            
        }) { (res) in
           
            completion(0,self.handleErrors(res))
            
        }
    }
    
    func tasksWithType(type : String, completion:([QBCOCustomObject]?, ServerErrorHandling?)->Void){
        
        let extendedReq = NSMutableDictionary()
        let taskLimit =  Int(convertdateToTimeinterval(NSDate(),dateFormat: "dd-MM-yyyy"))
        if type == "targetDate[lt]"
        {
            extendedReq.setValue(0, forKey: "isCompleted")
        }
        extendedReq.setValue(taskLimit, forKey: type)
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "user_id")
        QBRequest.objectsWithClassName("PLProjectCommitment", extendedRequest: extendedReq, successBlock: { (_, objects, _) in
           
            completion(objects,nil)
            
        }) { (res) in
            
            completion(nil,self.handleErrors(res))
        }
    }

    
    
       func countOfUpComingCommitments(completion:(UInt,ServerErrorHandling?) -> Void)
       {
        let timeInterval = Int(convertdateToTimeinterval(NSDate(),dateFormat: "dd-MM-yyyy"))
        let extendedReq = NSMutableDictionary()
        extendedReq.setValue(timeInterval, forKey: "startDate[gt]")
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "user_id")
        QBRequest.countObjectsWithClassName("PLProjectCommitment", extendedRequest: extendedReq, successBlock: { (_, count) in
 
            completion(count, nil)

            
        }){ (res) in
            
            completion(0, self.handleErrors(res))
            
        }

    }
    
    func countOfPendingTasks(completion:(UInt,ServerErrorHandling?) -> Void)
    {
        let timeInterval = Int(convertdateToTimeinterval(NSDate(),dateFormat: "dd-MM-yyyy"))
        let extendedReq = NSMutableDictionary()
        extendedReq.setValue(timeInterval, forKey: "targetDate[lt]")
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "user_id")
        extendedReq.setValue(0, forKey: "isCompleted")
        QBRequest.countObjectsWithClassName("PLProjectCommitment", extendedRequest: extendedReq, successBlock: { (_, count) in
 
           
            completion(count, nil)
            
        }){ (res) in
            
            completion(0, self.handleErrors(res))
            
        }

    }
    
    
    func findBirthdays(completion:(UInt,ServerErrorHandling?)->Void){
        
    let timeInterval = Int(convertdateToTimeinterval(NSDate(),dateFormat: "dd-MM"))
        
        let extendedReq = NSMutableDictionary()
        extendedReq.setValue(timeInterval, forKey: "birthday")
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "user_id")
        QBRequest.countObjectsWithClassName("PLProjectMember", extendedRequest: extendedReq, successBlock: { (_, count) in
            completion(count,nil)
          
        }){ (res) in
            
          completion(0,self.handleErrors(res))
        }
     }
    
    func upcomingBirthdays(completion:(UInt, ServerErrorHandling?)->Void){
        
        let timeInterval = Int(convertdateToTimeinterval(NSDate(),dateFormat: "dd-MM"))
        
        let extendedReq = NSMutableDictionary()
        extendedReq.setValue(timeInterval, forKey: "birthday[gt]")
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "user_id")
        QBRequest.countObjectsWithClassName("PLProjectMember", extendedRequest: extendedReq, successBlock: { (_, count) in
        
            completion(count,nil)
            
            
        }){ (res) in
            
            completion(0,self.handleErrors(res))
        }
    }
    
    func getBirthdayListOfTeamMembers(range:Int ,completion:([QBCOCustomObject]?,ServerErrorHandling?)->Void){
        var timeInterval = 0
        if range == 0
        {
        timeInterval = Int(convertdateToTimeinterval(NSDate(),dateFormat: "dd-MM"))
            let extendedReq = NSMutableDictionary()
            extendedReq.setValue(timeInterval, forKey: "birthday")
            extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "user_id")
            
            QBRequest.objectsWithClassName("PLProjectMember", extendedRequest: extendedReq, successBlock: { (_, objects, _) in
                
                completion(objects,nil)
                
            }) { (res) in
                
                print("Error is \(res)")
                completion(nil,self.handleErrors(res))
            }

        }
        else{
            timeInterval = Int(convertdateToTimeinterval(NSDate(), dateFormat: "dd-MM"))
            let extendedReq = NSMutableDictionary()
            extendedReq.setValue(timeInterval, forKey: "birthday[gt]")
            extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "user_id")
            
            QBRequest.objectsWithClassName("PLProjectMember", extendedRequest: extendedReq, successBlock: { (_, objects, _) in
                
                completion(objects,nil)
                
            }) { (res) in
                
                print("Error is \(res)")
                completion(nil,self.handleErrors(res))
            }

        }
    }
    
    func stringToDate(dateTime : String) -> NSDate
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let date = dateFormatter.dateFromString(dateTime) // you are getting an optional value
        return date!
    }

    func dateFormat(timeInterval : NSTimeInterval) -> String
    {
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.localTimeZone().secondsFromGMT)
        return dateFormatter.stringFromDate(date)
    }
    
    func convertdateToTimeinterval(date : NSDate,dateFormat:String) -> NSTimeInterval
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.localTimeZone().secondsFromGMT)
        
        let stringDate = dateFormatter.stringFromDate(date)
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let stringToDate = dateFormatter.dateFromString(stringDate)?.timeIntervalSince1970
        return stringToDate! // you are getting an optional value
    }
    
    func timeFormats(time: String) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let date = dateFormatter.dateFromString(time)
        
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.stringFromDate(date!) // you are getting an optional value
        return dateString
    }
    
    func saveUserBirthday(interval:UInt){
        
        let user = QBUpdateUserParameters()
        user.phone = String(interval)
        QBRequest.updateCurrentUser(user, successBlock: { (_, _) in
            
            // success
            
            }) { (_) in   // error response
             
        }
    }
    
    
    func updateAssigmentStatus(id:String?,status:Int,completion:(Bool, ServerErrorHandling?)->Void){
        
        print("updateRemoteAssigmentStatus\(id)")
        
        if status == -1{
         
            print("Close the assignment")
        }
        else{
        let userId = QBSession.currentSession().currentUser?.ID
        let customObject = QBCOCustomObject()
        customObject.className = "PLProjectAssignmentMember"
        customObject.ID = id
        customObject.fields?.setObject(status, forKey: "assigneeStatus")
        customObject.fields?.setObject(userId!, forKey:"assigneeUserId")
        QBRequest.updateObject(customObject, successBlock: { (_, _) in
            completion(true, nil)
            print("Updated Successfully")
            
            }) { (res) in
                completion(false, self.handleErrors(res))
        }
        }
    }
    
    func updateAssignmentStatusForMembers(status:Int,recordIds:[String],userIds:[UInt],completion:(Bool)->Void){
        
        var updateObjects = [QBCOCustomObject]()
        
        for (i,each) in recordIds.enumerate(){
            let customObject = QBCOCustomObject()
            customObject.className = "PLProjectAssignmentMember"
            customObject.ID = each
            customObject.fields?.setObject(status, forKey: "assigneeStatus")
            customObject.fields?.setObject(userIds[i], forKey:"assigneeUserId")
            updateObjects.append(customObject)
        }
        
        QBRequest.updateObjects(updateObjects, className: "PLProjectAssignmentMember", successBlock: { (_, objects, _) in
            
            completion(true)
            print("Updated succesfully")
            
            }) { (_) in
              
                completion(false)
                print("error occured")
        }
    }
    
    
    
    func getAssignmentMembersForAssignmentId(id:String,completion:([QBCOCustomObject]?,ServerErrorHandling?) -> Void)
    {
        
        let extendedReq = NSMutableDictionary()
        extendedReq.setValue(id, forKey: "_parent_id")
        
        QBRequest.objectsWithClassName("PLProjectAssignmentMember", extendedRequest:extendedReq, successBlock: { (_, objects, _) in
        
            if let _ = objects{
                
                completion(objects!, nil)
            }
            
            
            }) { (res) in
                
              completion(nil,self.handleErrors(res))
        }
    }
    
    
    func countOfTodayAssignments(completion:(UInt, ServerErrorHandling?)->Void){
        
        let extendedReq = NSMutableDictionary()
        
        
        let timeInterval = Int(convertdateToTimeinterval(NSDate(),dateFormat: "dd-MM-yyyy"))
        extendedReq.setValue(timeInterval, forKey: "startDate")
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "assigneeUserId[or]")
        QBRequest.countObjectsWithClassName("PLProjectAssignment", extendedRequest: extendedReq, successBlock: { (res, count) in
            completion(count, nil)
            
        }) { (res) in
            completion(0,self.handleErrors(res))
        }
    }
    
    func countOfUpComingAssignments(completion:(UInt, ServerErrorHandling?) -> Void)
    {
        let timeInterval = Int(convertdateToTimeinterval(NSDate(),dateFormat: "dd-MM-yyyy"))
        let extendedReq = NSMutableDictionary()
        extendedReq.setValue(timeInterval, forKey: "startDate[gt]")
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "assigneeUserId[or]")
        QBRequest.countObjectsWithClassName("PLProjectAssignment", extendedRequest: extendedReq, successBlock: { (_, count) in
            
            completion(count, nil)
            
            }) { (error) in
                
                completion(0,self.handleErrors(error))
                print("got error")
           }
    }
    
    func countOfPendingAssignments(completion : (UInt, ServerErrorHandling?) -> Void)
    {
        let timeInterval = Int(convertdateToTimeinterval(NSDate(),dateFormat: "dd-MM-yyyy"))
        let extendedReq = NSMutableDictionary()
        extendedReq.setValue(timeInterval, forKey: "targetDate[lt]")
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "assigneeUserId[or]")
        extendedReq.setValue(0, forKey: "status")
        QBRequest.countObjectsWithClassName("PLProjectAssignment", extendedRequest: extendedReq, successBlock: { (_, count) in
            
            
            completion(count, nil)
            
        }){ (res) in
            
            completion(0, self.handleErrors(res))
            
        }
        
    }

    func assignmentsWithType(type : String, completion:([QBCOCustomObject]?, ServerErrorHandling?)->Void){
        
        let extendedReq = NSMutableDictionary()
        let taskLimit =  Int(convertdateToTimeinterval(NSDate(),dateFormat: "dd-MM-yyyy"))
        if type == "targetDate[lt]"
        {
            extendedReq.setValue(0, forKey: "status")
        }
        extendedReq.setValue(taskLimit, forKey: type)
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "assigneeUserId[or]")
        QBRequest.objectsWithClassName("PLProjectAssignment", extendedRequest: extendedReq, successBlock: { (_, objects, _) in
            
            completion(objects, nil)
           
        }) { (res) in
           
            completion(nil, self.handleErrors(res))
        }
    }
 
    
    func closeAssignment(id:String,completion:(Bool, ServerErrorHandling?)->Void){
        
        let assignment = QBCOCustomObject()
        assignment.className = "PLProjectAssignment"
        assignment.parentID = PLSharedManager.manager.projectId
        assignment.ID = id
        assignment.fields?.setObject(-1, forKey: "status")
        print(id)
        QBRequest.updateObject(assignment, successBlock: { (_, _) in
            
            print("closed succesfully")
            
            completion(true, nil)
            
        }) { (error) in
            
            completion(false, self.handleErrors(error))
            print("got error")
        }
    }
    
    func updateAssignmentPercentage(record:String,value:Int){
    
        let assignment = QBCOCustomObject()
        assignment.className = "PLProjectAssignmentMember"
        assignment.ID = record
        assignment.fields?.setObject(value, forKey: "percentageCompleted")
       
        QBRequest.updateObject(assignment, successBlock: { (_, _) in
            
            print("UPdated succesfully")
            
           
            
        }) { (error) in
            
          
            print("got error")
        }
    }
    
    func deleteCommitment(id : String, completion:(Bool, ServerErrorHandling?)-> Void)
    {
        QBRequest.deleteObjectWithID(id, className: "PLProjectCommitment", successBlock: { (res) in
            print(res)
            completion(true,nil)
            }) { (error) in
              completion(false,self.handleErrors(error))
        }
    }
   
    func deleteAssignment(id : String, completion:(Bool, ServerErrorHandling?)-> Void)
    {
        QBRequest.deleteObjectWithID(id, className: "PLProjectAssignment", successBlock: { (res) in
            print(res)
            completion(true,nil)
        }) { (error) in
            completion(false,self.handleErrors(error))
        }
    }
    
    //sending group craeation invitation
    
/*createdDialog!.occupantIDs?.forEach({ (occupantID) in
 
 let inviteMessage: QBChatMessage = self.createChatNotificationForGroupChatCreation(chatDialog)
 let timestamp: NSTimeInterval = NSDate().timeIntervalSince1970
 inviteMessage.customParameters?.setValue(timestamp, forKey: "date_sent")
 inviteMessage.recipientID = occupantID.unsignedLongValue
 QBChat.instance().sendSystemMessage(inviteMessage) { (error: NSError?) -> Void in
 if error == nil{
 print("Sent Successfullly")
 }
 else
 {
 print(error?.localizedDescription)
 }
 }
 })*/
 
}