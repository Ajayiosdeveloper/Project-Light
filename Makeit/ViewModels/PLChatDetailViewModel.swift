//
//  PLChatDetailViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 05/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLChatDetailViewModel: NSObject {
    
    var selectedChatGroup:PLChatGroup!
    
    init(chatGroup:PLChatGroup) {
        
        selectedChatGroup = chatGroup
    }
    
    

}
