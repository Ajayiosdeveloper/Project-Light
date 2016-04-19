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
        
            self.initiateUserLogin(name, password:password, completion: {[weak self] (com) -> Void in
                completion(com)
                self!.saveUserCredentialsInDefaults(name,password:password)
            })
                
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
        NSUserDefaults.standardUserDefaults().setValue(retrievedUser?.ID, forKey:"USER_ID")
        completion(true)
        SVProgressHUD.dismiss()
        
        }) { (error) -> Void in
          
          completion(false)
          SVProgressHUD.dismiss()
        }
    }
    
    //Saving login credentials to Defaults
    
    func  saveUserCredentialsInDefaults(name:String,password:String){
        NSUserDefaults.standardUserDefaults().setValue(name, forKey:"USER_NAME")
        NSUserDefaults.standardUserDefaults().setValue(password, forKey:"USER_PASSWORD")
    }
    
    //Creating a New Project in QuickBlox
    
    func createNewProjectWith(name:String,description:String,completion:(Bool)->Void) {
        
        let customObject = QBCOCustomObject()
        customObject.className = "PLProject"
        customObject.fields?.setValue(name, forKey: "name")
        customObject.fields?.setValue(description, forKey: "description")
        QBRequest.createObject(customObject, successBlock: { (response,object) in
            
            completion(true)
            
          }) { (response) in
                
                completion(false)
        }
    }
    
    func fetchProjectsOfUserWith(completion:(result:[AnyObject]?)->Void) {
        
        let extendedParameters = NSMutableDictionary()
        
        let userId = QBSession.currentSession().currentUser?.ID
        
        extendedParameters["user_id"] = userId
        
        QBRequest.objectsWithClassName("PLProject", extendedRequest:extendedParameters, successBlock: { (res,objects,page) in
            
               completion(result:objects)
            
            }) { (response) in
                
                
        }
   }
    
    func userLogout() {
        
        QBRequest.logOutWithSuccessBlock({ (response) in
            
            
            }, errorBlock:nil)
    
    }

}