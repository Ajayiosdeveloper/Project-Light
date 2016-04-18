//
//  PLProjectsViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 16/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLProjectsViewModel: NSObject {
    
     var projectList:[PLProject] = [PLProject]()
    
    var quickBloxClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()
    
   override init() {
        
        super.init()
    
        fetchProjectsFromRemote()
    
    }
   
    func fetchProjectsFromRemote() {
        
        quickBloxClient.fetchProjectsOfUserWith{(result) in
            
            if let _ = result{
                
                let objects = result! as [AnyObject]
                
                self.fillProjectListArrayWithContents(objects)
            }
        }
    
    }
    
    func fillProjectListArrayWithContents(container:[AnyObject]){
    
        for (i,_) in container.enumerate()
        {
            let remoteObject = container[i] as! QBCOCustomObject
            
           
            
            
            let name = remoteObject.fields!["name"] as! String
            let description = remoteObject.fields!["description"] as? String
            let project = PLProject(projectName:name, subTitle:description!)
            project.projectId = remoteObject.ID
            project.createdBy = remoteObject.userID
            project.parentId = remoteObject.parentID
            projectList.append(project)
        }
        
        willChangeValueForKey("projectList")
        didChangeValueForKey("projectList")
    }
    
    
    func rowsCount() -> Int {
        
        return self.projectList.count
    }
    
    func titleAtIndexPath(indexPath:NSInteger) -> String {
        
        let project = projectList[indexPath]
        return project.name
    }
    
    func subTitleAtIndexPath(indexPath:NSInteger) -> String {
        
        let project = projectList[indexPath]
        return project.subTitle
    }
    
    func didSelectRowAtIndex(index:Int) -> PLProject {
        
        return projectList[index]
    }

}
