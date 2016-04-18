//
//  AddProjectViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 18/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLAddProjectViewModel: NSObject {
    
    var quickBloxClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()

    func createNewProjectWith(name:String,description:String){
        
        quickBloxClient.createNewProjectWith(name, description: description)
    }
    
}
