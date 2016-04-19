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
    var isProjectCreated:Bool = false
    
    func validateProjectDetails(name:String) -> Bool {
        
        if name.characters.count == 0
        {
            return false
        }
       return true
    }

    func createNewProjectWith(name:String,description:String){
        
        quickBloxClient.createNewProjectWith(name, description: description){[weak self]result in
            self!.isProjectCreated = result
            self!.willChangeValueForKey("isProjectCreated")
            self!.didChangeValueForKey("isProjectCreated")
        }
    }
    
}
