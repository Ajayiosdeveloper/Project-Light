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
    
    func fetchAllGroupMessages(completion:(Bool)->Void){
    
        qbClient.getMessagesFromChatGroup(selectedChatGroup.chatGroupId){[weak self](res,messages) in
            
            if res && messages != nil{
                
                self!.groupChatMessages = messages!
                completion(true)
            }
            else{
                self!.groupChatMessages = [JSQMessage]()
                completion(false)
            }
            
        }
    }
    
    
    func sendMessage(group:QBChatDialog,text:String,attachment:NSData?,completion:(Bool)->Void){
        
        if attachment == nil{
            
            qbClient.sendMessageWithoutAttachment(text, group: group){res in
                
                completion(res)
            }
        }
        else{
            
            qbClient.sendMessageWithAttachment(attachment!, text: text, group: group){res in
                
                completion(res)
            }
        }
    }
    
    
}
