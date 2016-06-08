//
//  PLChatDetailViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 05/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLChatDetailViewModel: NSObject {
    
    var selectedChatGroup:PLChatGroup!
    
    var groupChatMessages:[JSQMessage] = [JSQMessage]()
    
    var qbClient = PLQuickbloxHttpClient()
    
    init(chatGroup:PLChatGroup) {
        
        selectedChatGroup = chatGroup
    }
    
    func fetchAllGroupMessages(completion:(Bool, ServerErrorHandling?)->Void){
    
        qbClient.getMessagesFromChatGroup(selectedChatGroup.chatGroupId){[weak self](res,messages,error) in
            
            if res && messages != nil{
                
                self!.groupChatMessages = messages!
                completion(true, nil)
            }
            else{
                self!.groupChatMessages = [JSQMessage]()
                completion(false, error)
            }

        }
    }
    
    
    func sendMessage(group:QBChatDialog,text:String,attachment:NSData?,completion:(Bool, ServerErrorHandling?)->Void){
        
        if attachment == nil{
            
            qbClient.sendMessageWithoutAttachment(text, group: group){res in
                
                completion(res, nil)
            }
        }
        else{
            
            qbClient.sendMessageWithAttachment(attachment!, text: text, group: group){res in
                
                completion(res)
            }
        }
    }
    
    func updateChatUnreadMessagesCount(){
      selectedChatGroup.unReadMessageCount = 0
    }
    
    
}
