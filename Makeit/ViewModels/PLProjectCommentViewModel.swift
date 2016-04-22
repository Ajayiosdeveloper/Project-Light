//
//  PLProjectCommentViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

enum CommitValidation:ErrorType {
    case NameEmpty,InvalidDate,DescriptionEmpty
}

class PLProjectCommentViewModel: NSObject {
    
    var qbClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()
    
    func createCommitmentWith(name:String,targetDate:NSDate,description:String,projectId:String,completion:(Bool)->Void){
        
        print(name)
        print(targetDate)
        print(description)
        print(projectId)
        let targetDateString = NSDateFormatter.localizedStringFromDate(targetDate, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        qbClient.createCommitmentForProject(projectId, date:targetDateString, name: name, description:description){ result in
           
            completion(result)
        }
    }
    
    func commitmentValidations(name:String,targetDate:NSDate,description:String) throws->Bool {
        
        if name.characters.count == 0 { throw CommitValidation.NameEmpty}
        let today = NSDate()
        if (targetDate.earlierDate(today).isEqualToDate(targetDate)){
            
            throw CommitValidation.InvalidDate
        }
        if description.characters.count == 0
        {
            throw CommitValidation.DescriptionEmpty
        }
       
        return true
    }

}
