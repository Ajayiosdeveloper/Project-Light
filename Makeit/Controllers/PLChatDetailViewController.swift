//
//  PLChatDetailViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 04/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLChatDetailViewController: QMChatViewController {
    
    var chatDetailViewModel:PLChatDetailViewModel!
    var chatGroup: QBChatDialog!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderID = (QBSession.currentSession().currentUser?.ID)!
        self.senderDisplayName = QBSession.currentSession().currentUser?.login
        self.title = "Truth"
        self.view.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: NSDate!) {
        
    }
    
/*let user = QBUUser()
 user.ID = (QBSession.currentSession().currentUser?.ID)!
 user.password = "12121212"
 QBChat.instance().connectWithUser(user) { (error: NSError?) -> Void in
 if error == nil{
 print("Success in connection")
 
 
 self.chatGroup = QBChatDialog(dialogID:self.chatDetailViewModel.selectedChatGroup.chatGroupId, type: QBChatDialogType.Group)
 self.chatGroup.occupantIDs = self.chatDetailViewModel.selectedChatGroup.opponents
 self.chatGroup.joinWithCompletionBlock { (err) in
 if err == nil{
 print("Joined Succesfully")
 
 
 let message: QBChatMessage = QBChatMessage()
 message.text = "PRAISE THE LORD"
 let params = NSMutableDictionary()
 params["save_to_history"] = true
 message.customParameters = params
 message.deliveredIDs = [(QBSession.currentSession().currentUser?.ID)!]
 message.readIDs = [(QBSession.currentSession().currentUser?.ID)!]
 message.markable = true
 
 self.chatGroup.sendMessage(message, completionBlock: { (error: NSError?) -> Void in
 
 if err == nil{
 print(message.text)
 print("Message sent Succesfully")
 
 let resPage = QBResponsePage(limit:20, skip: 0)
 
 QBRequest.messagesWithDialogID(self.chatDetailViewModel.selectedChatGroup.chatGroupId, extendedRequest: nil, forPage: resPage, successBlock: {(response: QBResponse, messages: [QBChatMessage]?, responcePage: QBResponsePage?) in
 
 print("Messages count is \(messages?.count)")
 
 }, errorBlock: {(response: QBResponse!) in
 
 })
 
 }else{
 print(err?.localizedDescription)
 }
 
 });
 }
 else{
 print(err?.localizedDescription)
 }
 }
 
 }
 }*/


}