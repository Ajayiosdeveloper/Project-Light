//
//  PLQuickbloxHttpClient.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 16/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import Foundation
import Quickblox




class PLQuickbloxHttpClient
{
    //Creating New User Service with Quickblox
    func createNewUserWith(name:String,password:String,completion:(Bool)->Void)
    {
            let user = QBUUser()
            user.login = name
            user.password = password
            SVProgressHUD.showWithStatus("Signing up")
            QBRequest.signUp(user, successBlock: { (response, retrievedUser) -> Void in
            SVProgressHUD.dismiss()
                
                    completion(true)
            })
            { (errorResponse) -> Void in
                    
                  SVProgressHUD.dismiss()
                  completion(false)
            }
    
   }
    
    //User Login Service with Quickblok
    
    func initiateUserLogin(name:String,password:String,completion:(Bool)->Void){
        
       SVProgressHUD.showWithStatus("Loging in")
       QBRequest.logInWithUserLogin(name, password: password, successBlock: { (response, retrievedUser) -> Void in
        completion(true)
        SVProgressHUD.dismiss()
        
        }) { (error) -> Void in
          
          completion(false)
          SVProgressHUD.dismiss()
        }
    }
    
    
    
}