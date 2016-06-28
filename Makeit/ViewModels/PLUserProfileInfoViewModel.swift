//
//  PLUserProfileInfoViewModel.swift
//  Makeit
//
//  Created by Tharani P on 06/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLUserProfileInfoViewModel: NSObject {

    var qbClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()

    override init() {
        
        super.init()
    }
    
    func createUserProfileWith(dateOfBirth:NSDate, companyName:String?, technology:String?, experience:String?, designation: String?, emailId: String?,phoneNumber: String? ,completion:(Bool, ServerErrorHandling?) -> Void)
    {
        
        let targetDateString = NSDateFormatter.localizedStringFromDate(dateOfBirth, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        if let birthdayInterval = convertdateToTimeinterval(dateOfBirth){
            
           qbClient.saveUserBirthday(UInt(birthdayInterval))
        }
        
        qbClient.updateProfileOfAnUser(targetDateString, companyName: companyName, technology: technology, experience:experience, designation: designation, emailId: emailId, phoneNumber: phoneNumber){ result,err in
            if result
            {
                completion(result, nil)
            }
            else{
                completion(false, err)
            }
        }
   }

    func getUserProfileDetail(userId : UInt, completion:([String:AnyObject]?, ServerErrorHandling?)->Void)
    {
        qbClient.getUserProfileDetails(userId) { res,err in
            if err == nil
            {
            completion(res,nil)
            }
            else
            {
                completion([:],err)
            }
        }
    }
    
    func convertdateToTimeinterval(date : NSDate) -> NSTimeInterval?
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.localTimeZone().secondsFromGMT)
        
        let stringDate = dateFormatter.stringFromDate(date)
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let stringToDate = dateFormatter.dateFromString(stringDate)?.timeIntervalSince1970
        return stringToDate
    }
    
    
}
