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
        let user = QBUUser()
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
                    }
                }
            }
        }

      
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: NSDate!) {
        
        let chatMessage = QBChatMessage()
        chatMessage.text = "PRAISE THE LORD"
        chatMessage.senderID = (QBSession.currentSession().currentUser?.ID)!
        chatMessage.attachments = []
        self.chatSectionManager.addMessage(chatMessage)
        self.finishSendingMessageAnimated(true)
        
        let params = NSMutableDictionary()
        params["save_to_history"] = true
        chatMessage.customParameters = params
        chatMessage.deliveredIDs = [(QBSession.currentSession().currentUser?.ID)!]
        chatMessage.readIDs = [(QBSession.currentSession().currentUser?.ID)!]
        chatMessage.markable = true
        
        self.chatGroup.sendMessage(chatMessage, completionBlock: { (error: NSError?) -> Void in
            
            if error == nil{
                print(chatMessage.text)
            }
        })
        
    }
    
    
    override func viewClassForItem(item: QBChatMessage!) -> AnyClass! {
        
        if (item.senderID != self.senderID) {
            
            return QMChatIncomingCell.self;
        } else {
            
            return QMChatOutgoingCell.self;
        }
    }
    
    
    override func collectionView(collectionView: QMChatCollectionView!, dynamicSizeAtIndexPath indexPath: NSIndexPath!, maxWidth: CGFloat) -> CGSize {
        
        let chatMessage = QBChatMessage()
        chatMessage.text = "PRAISE THE LORD"
        chatMessage.senderID = (QBSession.currentSession().currentUser?.ID)!
        chatMessage.attachments = []
        
        let attributedString = self.attributedStringForItem(chatMessage)
        
        let size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSizeMake(maxWidth, CGFloat(MAXFLOAT)), limitedToNumberOfLines: 0)
        
        return size
    }
    
    override func collectionView(collectionView: QMChatCollectionView!, minWidthAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let chatMessage = QBChatMessage()
        chatMessage.text = "PRAISE THE LORD"
        chatMessage.senderID = (QBSession.currentSession().currentUser?.ID)!
        chatMessage.attachments = []
        let attributedString = chatMessage.senderID == self.senderID ? self.bottomLabelAttributedStringForItem(chatMessage) : self.topLabelAttributedStringForItem(chatMessage)
        
        let size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSizeMake(1000, 10000), limitedToNumberOfLines: 1)
        
        return size.width

        
    }
    
    
    override func attributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        
       let textColor = messageItem.senderID == self.senderID ? UIColor.whiteColor() : UIColor(white:0.29 , alpha:1.000)
        let font = UIFont(name:"Helvetica", size:15)
        let attributes = [
            NSFontAttributeName: font!,
            NSForegroundColorAttributeName: textColor
        ]
        let attrStr = NSMutableAttributedString(string: messageItem.text!, attributes:attributes)
        return attrStr;
    }
    
    override func topLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        
          let font = UIFont(name:"Helvetica", size:14)
        if (messageItem.senderID == self.senderID) {
            return nil;
        }
        let attributes = [
            NSFontAttributeName: font!,
            NSForegroundColorAttributeName: UIColor.greenColor()
        ]
        let attrStr = NSMutableAttributedString(string:"Messaiah", attributes:attributes)
        return attrStr;
    }
    
    override func bottomLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        
        let textColor = messageItem.senderID == self.senderID ? UIColor.greenColor() : UIColor.blackColor()
        let font = UIFont(name:"Helvetica", size:12)

        
        let attributes = [
            NSFontAttributeName: font!,
            NSForegroundColorAttributeName: textColor
        ]
        let attrStr = NSMutableAttributedString(string:"PRAISE THE LORD", attributes:attributes)
        
        return attrStr;
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