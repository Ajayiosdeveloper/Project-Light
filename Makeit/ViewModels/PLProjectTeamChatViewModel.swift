//
//  PLProjectTeamChatViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 02/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLProjectTeamChatViewModel: NSObject {
    
    var projectTeamMembers:[PLTeamMember]!
    
    init(teamMembers:[PLTeamMember]) {
        
        projectTeamMembers = teamMembers
    }

}
