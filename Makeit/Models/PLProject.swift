//
//  PLProject.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 18/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLProject: NSObject {
    
    var name:String
    var subTitle: String?
    var createdBy:UInt
    var projectId:String?
    var parentId:String?
    
    
    init(projectName:String,subTitle:String? = nil) {
        
        name = projectName
        self.subTitle = subTitle
        createdBy = 0
        projectId = nil
        parentId = nil
    }
    

}
