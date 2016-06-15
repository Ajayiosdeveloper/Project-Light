//
//  PLChatDetailViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 04/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

enum AttachmentType{
    
    case Image,Audio,Video
}

class PLChatDetailViewController: JSQMessagesViewController, UIActionSheetDelegate,QBChatDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
   
    var chatDetailViewModel:PLChatDetailViewModel!
    var chatGroup:QBChatDialog!
    var imagePickerController:UIImagePickerController!
    var attachment:NSData!
    var notificationBanner:AFDropdownNotification!
    //var selectedChatGroupIndex:Int = 0
 
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        QBChat.instance().addDelegate(self)
        self.chatGroup = QBChatDialog(dialogID:self.chatDetailViewModel.selectedChatGroup.chatGroupId, type: QBChatDialogType.Group)
        self.chatGroup.occupantIDs = self.chatDetailViewModel.selectedChatGroup.opponents
        self.chatGroup.joinWithCompletionBlock { (err) in
            if err == nil{
                print("Joined Succesfully")
            }
        self.title = self.chatDetailViewModel.selectedChatGroup.name
        self.senderID = String((QBSession.currentSession().currentUser?.ID)!)
        self.senderDisplayName = "You"
        
            self.chatDetailViewModel.fetchAllGroupMessages(){res in
            
                self.collectionView.reloadData()
            }

            
            self.collectionView.messagesCollectionViewLayout.incomingAvatarViewSize = CGSizeMake(30, 30)
            self.collectionView.messagesCollectionViewLayout.outgoingAvatarViewSize = CGSizeMake(30, 30)
            self.showLoadEarlierMessagesHeader = true
       
    }
    
    }
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        //self.collectionView.messagesCollectionViewLayout.springinessEnabled = true
    }
    

    
    // MARK: - JSQMessagesViewController method overrides
    
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        
         chatDetailViewModel.sendMessage(chatGroup, text: text, attachment: attachment) {[weak self] (res,err) in
                
                if res{
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    
                    if self!.attachment == nil{
                    let localMessage = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
                    self!.chatDetailViewModel.groupChatMessages.append(localMessage)
                    }
                    self!.finishSendingMessage()
                    self!.attachment = nil
                }
                
            }
    }
    
    func sendMessageWithImageAttachment(type:AttachmentType){
        
        chatDetailViewModel.sendMessage(chatGroup, text: "Forever and Evermore!", attachment: attachment) {[weak self] (res,err) in
            
            if res{
               
                if type == .Image{
                let photoItem = JSQPhotoMediaItem(image: UIImage(data:self!.attachment))
                let photoMessage = JSQMessage.message(senderId:self!.senderID, senderDisplayName:self!.senderDisplayName, media: photoItem)
                self!.chatDetailViewModel.groupChatMessages.append(photoMessage)
                }
                else if type == .Video{
                  
                }
                self!.finishSendingMessage()
                self!.attachment = nil
            }
            else
            {
                PLSharedManager.showAlertIn(self!, error: err!, title: "Error occured while attaching the image", message: err.debugDescription)
            }
          }
        }
    
   
    
    override func didPressAccessoryButton(sender: UIButton) {
        
        let sheet = UIActionSheet(title: "Media messages", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Send photo", "Send video")
        //sheet.showFromToolbar(self.inputToolbar)
        sheet.showInView(self.view)
    }
    
   func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        
        if buttonIndex == actionSheet.cancelButtonIndex {
            
            return
        }
        
        switch buttonIndex {
        case 1:
            
           self.showImagePicker(0)
          
        case 2:
            
            self.showImagePicker(1)

        default:
            
            print("")
        }
    }
    
    // MARK: - JSQMessages CollectionView DataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageData {
        
        return self.chatDetailViewModel.groupChatMessages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource {
        
        let message =  self.chatDetailViewModel.groupChatMessages[indexPath.item]

        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImage(color: UIColor.jsq_messageBubbleGreenColor())
        
        let incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImage(color: UIColor.jsq_messageBubbleLightGrayColor())
        
        if message.senderID == self.senderID {
            
            return outgoingBubbleImageData
        }
        
        return incomingBubbleImageData
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        
      let imageData = JSQMessagesAvatarImage(avatarImage:UIImage(named:"chatUser.png"), highlightedImage:UIImage(named:"chatUser.png" ), placeholderImage:UIImage(named:"chatUser.png")!)
        
        return imageData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        
        if indexPath.item%3 == 0 {
             let message =  self.chatDetailViewModel.groupChatMessages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter.attributedTimestamp(message.date)
        }
        
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        
               let message =  self.chatDetailViewModel.groupChatMessages[indexPath.item]
       
        if message.senderID == self.senderID {
            
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            
            let previousMessage =  self.chatDetailViewModel.groupChatMessages[indexPath.item - 1]
            if previousMessage.senderID == message.senderID {
                
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        
        return nil
    }
    
    // MARK: - UICollectionView DataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.chatDetailViewModel.groupChatMessages.count//self.demoModel.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let msg =  self.chatDetailViewModel.groupChatMessages[indexPath.item]

        if !msg.isMediaMessage {
            
            if msg.senderID == self.senderID {
                
                cell.textView?.textColor = UIColor.whiteColor()
                
                
            }
            else {
                
                cell.textView?.textColor = UIColor.blackColor()
            }
            
            cell.textView?.linkTextAttributes = [
                NSForegroundColorAttributeName: cell.textView!.textColor!,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
            ]
        }
        
        return cell
    }
    
    // MARK: - JSQMessages collection view flow layout delegate
    
    // MARK: - Adjusting cell label heights
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
        if indexPath.item % 3 == 0 {
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let currentMessage =  self.chatDetailViewModel.groupChatMessages[indexPath.item]

        if currentMessage.senderID == self.senderID {
            
            return 0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage =  self.chatDetailViewModel.groupChatMessages[indexPath.item - 1]

            if previousMessage.senderID == currentMessage.senderID {
                
                return 0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout: JSQMessagesCollectionViewFlowLayout, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 0
    }
    
    // MARK: - Responding to collection view tap events
    
    func collectionView(collectionView: JSQMessagesCollectionView, header: JSQMessagesLoadEarlierHeaderView, didTapLoadEarlierMessagesButton button: UIButton?) {
        
        if notificationBanner == nil{
            notificationBanner = AFDropdownNotification()
        }
        notificationBanner.titleText = "Message box is empty"
        notificationBanner.subtitleText = "No more messages in \(self.chatDetailViewModel.selectedChatGroup.name)"
        notificationBanner.image = UIImage(named: "emptyMessages.png")
        notificationBanner.dismissOnTap = true
        notificationBanner.presentInView(self.view, withGravityAnimation: false)
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, didTapAvatarImageView imageView: UIImageView, atIndexPath indexPath: NSIndexPath) {
        
        print("Tapped avatar!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath) {
        
        print("Tapped message bubble!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, didTapCellAtIndexPath indexPath: NSIndexPath, touchLocation: CGPoint) {
        
        print("Tapped cell at \(NSStringFromCGPoint(touchLocation))!")
    }
    
    func chatRoomDidReceiveMessage(message: QBChatMessage, fromDialogID dialogID: String) {
        
        print(message)
        if dialogID == self.chatDetailViewModel.selectedChatGroup.chatGroupId{
            
            if self.senderID == String(message.senderID){
                
                print("Do not show message")
            }
            else{
                
                print("Show Message")
                let name = message.customParameters?.objectForKey("name") as! String
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                let localMessage = JSQMessage(senderId:String(message.senderID), senderDisplayName:name, date:message.dateSent!, text:message.text!)
                self.chatDetailViewModel.groupChatMessages.append(localMessage)
                self.finishSendingMessage()
            }
        }
        else{
            
            print("Message came from other Chat Group")
            
        }
 }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
       /* let type = info[UIImagePickerControllerMediaType] as! String
        print(type)
        if type == "public.image"{
            attachment = nil
            let image = info[UIImagePickerControllerEditedImage] as! UIImage
            attachment = UIImagePNGRepresentation(image)
            sendMessageWithImageAttachment(.Image)
        }
        else if type == "public.audio"{
            
            let url = info[UIImagePickerControllerMediaURL] as! NSURL
            attachment = nil
            attachment = NSData(contentsOfURL:url)
            sendMessageWithImageAttachment(.Audio)
            
        }
        else if type == "public.video"{
            
            let url = info[UIImagePickerControllerMediaURL] as! NSURL
            attachment = nil
            attachment = NSData(contentsOfURL:url)
            sendMessageWithImageAttachment(.Video)
        }*/
       self.imagePickerController.dismissViewControllerAnimated(true, completion: nil)
       
    }
    
    func showImagePicker(value:Int){
        
        if imagePickerController == nil{
            
            self.imagePickerController = UIImagePickerController()
            self.imagePickerController.delegate = self
        }
        if value == 0{
            self.imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.imagePickerController.allowsEditing = true
           
        }else if value == 1{
            
            self.imagePickerController.mediaTypes = [kUTTypeMP3 as String,kUTTypeMovie as String,kUTTypeQuickTimeMovie as String]
            
            
        }
       
        self.navigationController?.presentViewController(self.imagePickerController, animated: true, completion:nil)

        }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        chatDetailViewModel.updateChatUnreadMessagesCount()
    }
    
 
}

