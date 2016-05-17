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
    func createNewUserWith(name:String,password:String,email:String,completion:(Bool)->Void)
    {
        let user = QBUUser()
        user.login = name
        user.fullName = name
        user.password = password
        user.email = email
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
            PLSharedManager.manager.userName = name
            PLSharedManager.manager.userPassword = password
            
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
        customObject.fields?.setValue(PLSharedManager.manager.userName, forKey: "projectCreatorName")
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
    
    func createCommitmentForProject(id:String,startDate : Int, targetDate:Int, name:String, description:String, startTime : String, endTime: String, completion:(Bool)->Void) {
        
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
        QBRequest.createObject(customObject, successBlock: { (response,object) in
            
            print("PRAISE THE LORD")
            completion(true)
            
        }) { (res) in
            
            completion(false)
            print("Handle error")
        }
    }
    
    //Create Assignment for Project in QuickBlox
    
    func createAssignmentForProject(id:String,startDate: Int, targetDate:Int, name:String,description:String,assignees:[String],assigneeUserIds:[UInt],startTime : String, endTime: String, completion:(Bool)->Void) {
        
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
                 //   plAssignment.targetDate = assignment.fields?.objectForKey("targetDate") as! String
                  //  plAssignment.startDate = assignment.fields?.objectForKey("startDate") as! String
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
    
    //Creating a Chat Group for a Project
    
    func createChatGroupWitTeamMembers(name :String,  membersIds:[UInt],completion:(Bool,PLChatGroup?)->Void)
    {
        
        let chatDialog = QBChatDialog(dialogID: nil, type: QBChatDialogType.Group)
        chatDialog.name = "\(name) \(PLSharedManager.manager.projectId)"
        chatDialog.occupantIDs = membersIds
        QBRequest.createDialog(chatDialog, successBlock: { (response: QBResponse?, createdDialog : QBChatDialog?) -> Void in
            let chatGroup = PLChatGroup()
            chatGroup.name = name
            chatGroup.opponents = (createdDialog?.occupantIDs)!
            chatGroup.chatGroupId = (createdDialog?.roomJID)!
            chatGroup.unReadMessageCount = 0
            completion(true,chatGroup)
            
        }) { (responce : QBResponse!) -> Void in
            
            print("The Response is \(responce)")
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
    
    
    func fetchChatGroupsForProject(completion:(Bool,[PLChatGroup])->Void){
        
        let searchString = PLSharedManager.manager.projectId
        
        let extendedRequest = ["name[ctn]" : searchString]
        
        let page = QBResponsePage(limit: 20, skip: 0)
        
        QBRequest.dialogsForPage(page, extendedRequest:extendedRequest, successBlock: {[weak self] (response: QBResponse, dialogs: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, page: QBResponsePage?) -> Void in
            
            var chatGroups:[PLChatGroup] = [PLChatGroup]()
            
            if let _ = dialogs{
                
                for eachGroup in dialogs!{
                    
                    let chatGroup =  PLChatGroup()
                    chatGroup.name = self!.removeProjectIdFromChatGroupName((eachGroup.name)!)
                    chatGroup.chatGroupId = (eachGroup.ID)!
                    chatGroup.lastMessage = eachGroup.lastMessageText
                    chatGroup.unReadMessageCount = eachGroup.unreadMessagesCount
                    if let _ = eachGroup.lastMessageDate{
                        chatGroup.lastMessageDate = NSDateFormatter.localizedStringFromDate(eachGroup.lastMessageDate!, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                    }
                    chatGroup.opponents = eachGroup.occupantIDs!
                    chatGroups.append(chatGroup)
                }
            }
            
            completion(true,chatGroups)
            
        }) { (response: QBResponse) -> Void in
            
        }
        
    }
    
    func getMessagesFromChatGroup(groupId:String,completion:(Bool,[JSQMessage]?)->Void){
        
        let page = QBResponsePage(limit: 20, skip: 0)
        
        QBRequest.messagesWithDialogID(groupId, extendedRequest:nil, forPage:page, successBlock: { (_, messages, _) in
            
            var chatMessages = [JSQMessage]()
            
            if let _ = messages{
                
                
                
                for message in messages!{
                    
                    if message.attachments?.count > 0{
                        let attachmentDict = message.attachments?.first
                        let fileId = attachmentDict?.ID
                        QBRequest.downloadFileWithID(UInt(fileId!)!, successBlock: { (_, imageData) in
                            let imageUI = UIImage(data:imageData)
                            let attachedImage = JSQPhotoMediaItem(image:imageUI)
                            let eachMessage = JSQMessage(senderId:String(message.senderID), senderDisplayName: "Najareth", date: message.dateSent!, media:attachedImage)
                            chatMessages.append(eachMessage)
                            completion(true,chatMessages)
                            
                            }, statusBlock: { (_, _) in
                                
                            }, errorBlock: { (_) in
                                
                        })
                    }
                    else{
                        let eachMessage = JSQMessage(senderId:String(message.senderID), senderDisplayName:"Najareth", date:message.dateSent!, text: message.text!)
                        chatMessages.append(eachMessage)
                    }
                    
                }
                
                print(chatMessages.count)
                
                
            }
            
            completion(true,chatMessages)
            
            }, errorBlock:{(_)in
                
                completion(false,nil)
                
        })
        
    }
    
    func sendMessageWithoutAttachment(text:String,group:QBChatDialog,completion:(Bool)->Void){
        
        print("no attachment______________________________________________________________________________")
        
        let message: QBChatMessage = QBChatMessage()
        message.text = text
        let params = NSMutableDictionary()
        params["save_to_history"] = true
        message.customParameters = params
        message.deliveredIDs = [(QBSession.currentSession().currentUser?.ID)!]
        message.readIDs = [(QBSession.currentSession().currentUser?.ID)!]
        message.markable = true
        group.sendMessage(message, completionBlock: { (error: NSError?) -> Void in
            
            if error == nil{
                print(message.text)
                print("Message sent Succesfully")
                completion(true)
            }
        })
        
    }
    
    
    func sendMessageWithAttachment(imageData:NSData,text:String,group:QBChatDialog,completion:(Bool)->Void){
        
        print("attachment______________________________________________________________________________")
        
        QBRequest.TUploadFile(imageData, fileName: "image.png", contentType: "image/png", isPublic: false, successBlock: {(response: QBResponse!, uploadedBlob: QBCBlob!) in
            // Create and configure message
            let message: QBChatMessage = QBChatMessage()
            message.text = text
            let params = NSMutableDictionary()
            params["save_to_history"] = true
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
                    print(message.text)
                    print("Message sent Succesfully")
                    completion(true)
                }
            })
            
            }, statusBlock: {(request: QBRequest?, status: QBRequestStatus?) in
                
            }, errorBlock: {(response: QBResponse!) in
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
    
    
    func updateProfileOfAnUser(dateOfBirth:String?, companyName:String?, technology:String?, experience:String?, designation: String?,emailId : String?, completion:(Bool)->Void)
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
                    completion(true)
                    })
                { (respons) in
                    completion(false)
                    print("Error in Profile Creation")
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
                    completion(true)
                    
                }) { (res) in
                    completion(false)
                    print("Error in Profile Updation")
                }
                
            }
            
        }) { (_) in
            
            print("Error")
        }
    }
    
    
    func getUserProfileDetails(completion:([String:AnyObject]?)->Void)
    {
        let userId = QBSession.currentSession().currentUser?.ID
        
        let params = NSMutableDictionary()
        params.setValue(userId!, forKey:"_parent_id")
        QBRequest.objectsWithClassName("UserInfo", extendedRequest: params, successBlock: { (_,objects, _) in
            
            if objects?.count == 0
            {
                completion(nil)
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
                completion(infoDict)
            }
            
        }) { (_) in
            
            print("Error")
        }
    }
    
    func sendforgotPasswordLinkToEmail(email : String)
    {
        QBRequest.resetUserPasswordWithEmail(email, successBlock: { (response) in
            print("Suceesfully Sent")
        }) { (err) in
            print(err.description)
        }
        
    }
    
    
    
    func countOfTodayCommitments(completion:(UInt)->Void){
        
    let extendedReq = NSMutableDictionary()
        
        
        let timeInterval = Int(convertdateToTimeinterval(NSDate()))
        extendedReq.setValue(timeInterval, forKey: "startDate")
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "user_id")
        QBRequest.countObjectsWithClassName("PLProjectCommitment", extendedRequest: extendedReq, successBlock: { (res, count) in
            
            print("Here the count is Today")
            print(count)
            print(res)
            completion(count)
            
        }) { (res) in
           
            completion(0)
            
        }
    }
    
    
    func countOfUpComingCommitments(completion:(UInt)->Void){
        let timeInterval = Int(convertdateToTimeinterval(NSDate()))
        let extendedReq = NSMutableDictionary()
        extendedReq.setValue(timeInterval, forKey: "startDate[gt]")
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "user_id")
        QBRequest.countObjectsWithClassName("PLProjectCommitment", extendedRequest: extendedReq, successBlock: { (_, count) in
            
            print("Here the count is Tomorrow")
            print(count)
            completion(count)

            
        }){ (res) in
            
            completion(0)
            
        }

    }
    
    func contOfPendingTasks(completion:(UInt)->Void){
        let timeInterval = Int(convertdateToTimeinterval(NSDate()))
        let extendedReq = NSMutableDictionary()
        extendedReq.setValue(timeInterval, forKey: "endDate[lt]")
        extendedReq.setValue(QBSession.currentSession().currentUser?.ID, forKey: "user_id")
        extendedReq.setValue(0, forKey: "isCompleted")
        QBRequest.countObjectsWithClassName("PLProjectCommitment", extendedRequest: extendedReq, successBlock: { (_, count) in
           
            print("Here the count is Pending")
            print(count)
           
            completion(count)
            
        }){ (res) in
            
            completion(0)
            
        }

    }
    
    func convertdateToTimeinterval(date : NSDate) -> NSTimeInterval
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.localTimeZone().secondsFromGMT)
        
        let stringDate = dateFormatter.stringFromDate(date)
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let stringToDate = dateFormatter.dateFromString(stringDate)?.timeIntervalSince1970
        return stringToDate!
    }
    
   
    
}