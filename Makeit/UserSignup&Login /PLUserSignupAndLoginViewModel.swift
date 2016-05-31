//
//  PLUserSignupAndLoginViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 15/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import Foundation
//import DigitsKit

enum LocalValidations:ErrorType // Client side validations
{
    case EmptyConformPassword, PasswordMismatch,WeakPassword,WeakUserName,ImproperUserName
}

enum RemoteValidations:ErrorType // Server side Validations
{
    case Failed, Success
}

class PLUserSignupAndLoginViewModel : NSObject
{
    var quickBloxClient:PLQuickbloxHttpClient = PLQuickbloxHttpClient()
    
    dynamic var loginResultNotifier:Bool = false
    
    func validateUserLoginCredentials(withUserName:String,password:String,completion: (ServerErrorHandling?) -> Void)
    {
        do {
            try startProcessingUserLogin(withUserName, password: password, completion: { (err) in
                if err != nil
                {
                    completion(err)
                }
                })
        }
        catch RemoteValidations.Failed{}
        catch RemoteValidations.Success{}
        catch {print("Other")}
     }
 
    
    func validateUserSignupCredentials(withUserName:String,password:String,confirmPassword:String) throws -> Bool
    {
        guard isUserNameWeak(withUserName) else{
            throw LocalValidations.WeakUserName
        }
        guard !withUserName.containsString(" ") else{
            
            throw LocalValidations.ImproperUserName
        }
        guard isPasswordWeak(password) else
        {
            throw LocalValidations.WeakPassword
        }
        guard isPasswordMismatched(password, passTwo: confirmPassword) else{
            
            throw LocalValidations.PasswordMismatch
        }
        
        return true
    }
    
    
//    func makeTwoFactorAuthentication(controller:PLUserSignUpViewController,userName:String,password:String,email:String){
//        
//        let digits = Digits.sharedInstance()
//        digits.logOut()
//        let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
//        configuration.appearance = setDigitsTheme()
//        digits.authenticateWithViewController(controller, configuration: configuration) {[weak self]session, error in
//            if (session != nil)
//            {
//                
//                self!.startProcessingUserSignup(userName,password: password,email: email)
//                
//            }
//            else {
//                print(error.localizedDescription)
//            }
//        }
//        
//    }
//    
//    func setDigitsTheme()->DGTAppearance{
//        
//        
//        let theme = DGTAppearance()
//        theme.bodyFont = UIFont.systemFontOfSize(17)
//        theme.labelFont = UIFont.systemFontOfSize(17)
//        theme.accentColor = enableButtonColor
//        theme.backgroundColor = UIColor.whiteColor()
//        return theme;
//    }
    
    private  func startProcessingUserLogin(withUserName:String,password:String,completion:(ServerErrorHandling?)-> Void) throws ->Void
    {
        //if quickBloxClient == nil{ quickBloxClient = PLQuickbloxHttpClient() }
        
        quickBloxClient.initiateUserLogin(withUserName, password: password) {[weak self] (result,error) -> Void in
            if error == nil
            {
            self!.loginResultNotifier = result
             completion(nil)
            }
            else
            {
                print("Login error")
                print(error)
                completion(error)
            }
        }
    }
    
    func startProcessingUserSignup(withUserName:String,password:String,email:String,completion:(Bool,ServerErrorHandling?)->Void)
    {
        //if quickBloxClient == nil{ quickBloxClient = PLQuickbloxHttpClient() }
        
        quickBloxClient.createNewUserWith(withUserName, password: password, email: email) { (result, ServerErrorHandling) in
            if !result
            {
                completion(false,ServerErrorHandling)
            }
            else{
                completion(result,nil)

            }
        }
        
//        quickBloxClient.createNewUserWith(withUserName, password:password,email: email){result in
//           
//           completion(result,nil)
//        }
        
    }
    
    func isPasswordWeak(password:String)->Bool{
        
        if password.characters.count <= 7 {
            
            return false
        }
        
        return true
        
    }
    
    func isUserNameWeak(userName:String)->Bool
    {
        if userName.characters.count <= 2{
            
            return false
        }
        
        return true
    }
    
    func isPasswordMismatched(passOne:String,passTwo:String)->Bool
    {
        if passOne == passTwo
        {
            return true
        }
        
        return false
    }
    

    
    func sendForgotPasswordLinkToeMail(mailId : String, completion:(ServerErrorHandling?)-> Void)
    {
        quickBloxClient.sendforgotPasswordLinkToEmail(mailId) { (err) in
            if let _ = err
            {
                print("Errrrrror ")
                completion(err)
            }
            else{
                print("Errrrrror No")
                completion(nil)
            }
        }
    }
    

    func isValidEmail(email : String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailTest.evaluateWithObject(email)
        {
            return true
        }
        return false
    }
}