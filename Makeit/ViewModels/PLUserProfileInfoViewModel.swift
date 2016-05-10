//
//  PLUserProfileInfoViewModel.swift
//  Makeit
//
//  Created by Tharani P on 06/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLUserProfileInfoViewModel: NSObject {

    var userProfileData = NSMutableArray()
    var qbClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()

    override init() {
        
        super.init()
    }
    
    func createUSerProfileWith(dateOfBirth:NSDate, companyName:String?, technology:String?, experience:String?, designation: String?, emailId: String?, completion:(Bool)->Void)
    {
        
        let targetDateString = NSDateFormatter.localizedStringFromDate(dateOfBirth, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        qbClient.updateProfileOfAnUser(targetDateString, companyName: companyName, technology: technology, experience:experience, designation: designation, emailId: emailId){ result in
            
            completion(result)
        }
   }

    func getUserProfileDetail(completion:([String:AnyObject]?)->Void)
    {
        qbClient.getUserProfileDetails { res in
            
        completion(res)
           
    }
    }
    
}
