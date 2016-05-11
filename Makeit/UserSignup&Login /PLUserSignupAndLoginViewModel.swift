//
//  PLUserSignupAndLoginViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 15/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import Foundation
import DigitsKit

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
    
    dynamic var signupResultNotifier:Bool = false
    dynamic var loginResultNotifier:Bool = false
    
    func validateUserLoginCredentials(withUserName:String,password:String)  -> Bool
    {
        do { try startProcessingUserLogin(withUserName, password: password) }
        catch RemoteValidations.Failed{ return false}
        catch RemoteValidations.Success {return true}
        catch {print("Other")}
        return true
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
    
    
    func makeTwoFactorAuthentication(controller:PLUserSignUpViewController,userName:String,password:String,email:String){
        
        let digits = Digits.sharedInstance()
        digits.logOut()
        let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
        configuration.appearance = setDigitsTheme()
        digits.authenticateWithViewController(controller, configuration: configuration) {[weak self]session, error in
            if (session != nil)
            {
                
                self!.startProcessingUserSignup(userName,password: password,email: email)
                
            }
            else {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func setDigitsTheme()->DGTAppearance{
        
        
        let theme = DGTAppearance()
        theme.bodyFont = UIFont.systemFontOfSize(17)
        theme.labelFont = UIFont.systemFontOfSize(17)
        theme.accentColor = enableButtonColor
        theme.backgroundColor = UIColor.whiteColor()
        return theme;
    }
    
    private  func startProcessingUserLogin(withUserName:String,password:String) throws ->Void
    {
        //if quickBloxClient == nil{ quickBloxClient = PLQuickbloxHttpClient() }
        
        quickBloxClient.initiateUserLogin(withUserName, password: password) {[weak self] (result) -> Void in
            
            self!.loginResultNotifier = result
        }
    }
    
    func startProcessingUserSignup(withUserName:String,password:String,email:String)
    {
        //if quickBloxClient == nil{ quickBloxClient = PLQuickbloxHttpClient() }
        
        quickBloxClient.createNewUserWith(withUserName, password:password,email: email){[weak self]result in
            
            self!.signupResultNotifier = result
        }
        
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
    
    func sendForgotPasswordLinkToeMail(mailId : String)
    {
        quickBloxClient.sendforgotPasswordLinkToEmail(mailId)
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