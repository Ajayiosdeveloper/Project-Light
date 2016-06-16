//  That at the name of Jesus every knee should bow, of things in heaven, and things in earth and things under the earth; And that every tongue should confess that Jesus Christ is Lord, to the glory of God the Father.Amen. Philippians 2: 10,11.
//  AppDelegate.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 12/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//  Project Light is the confidential initiation for Makeit Project.


import UIKit
//import Fabric
//import DigitsKit
import Quickblox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,QBChatDelegate {

    var window: UIWindow?
    var reachability:Reachability!
    var notificationBanner:AFDropdownNotification!
    var showBirthdayGreeting:PLShowBirthdayCardViewController!
    var projectDetail : PLProjectDetailTableViewController!
    var projectViewModel:PLProjectsViewModel!
    var storyBoard:UIStoryboard!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
       
        //Connecting Client Application with Quickblox API
        QBSettings.setApplicationID(kApplicationId)
        QBSettings.setAuthKey(kAuthorizationKey)
        QBSettings.setAuthSecret(kAuthorizationSecret)
        QBSettings.setAccountKey(kAccountKey)
        
        QBChat.instance().addDelegate(self)
        
        //Checking Newtwork Reachability and observing Newtork changes with observer
        
        reachability = Reachability.reachabilityForInternetConnection()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.handleNetworkChanges), name:kReachabilityChangedNotification, object:nil)
      reachability.startNotifier()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
        
        }

    func applicationWillEnterForeground(application: UIApplication) {
       
        UIApplication.sharedApplication().applicationIconBadgeNumber = -1
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }

      func handleNetworkChanges(){ //correct the spelling
        
        let remoteHost = reachability.currentReachabilityStatus() as NetworkStatus
        if remoteHost == NotReachable
        {
          
        }
        else
        {
          
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let deviceIdentifier = UIDevice.currentDevice().identifierForVendor?.UUIDString
        let subscription = QBMSubscription()
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        subscription.notificationChannel = QBMNotificationChannel.init(1)
        QBRequest.createSubscription(subscription, successBlock: { (_, _) in
            
            
        }) { (_) in
        }
        
        
    }
    
    func application(
        application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: NSError
        ) {
        //Log an error for debugging purposes, user doesn't need to know
        NSLog("Failed to get token; error: %@", error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
        storyBoard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
        
        let badgeCount = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = badgeCount
       
        let notificationTypeIdentifier = userInfo["Type"] as! String
        
        if notificationTypeIdentifier == "ASSIGNMENT"{
            
            let projectId = userInfo["projectId"] as! String
            let projectName = userInfo["projectName"] as! String

            presentProjectDetailViewController(projectId,projectName:projectName)

        }
        else if notificationTypeIdentifier == "BIRTHDAY"{
           
            if showBirthdayGreeting == nil{
             
                let aps = userInfo["aps"] as! [String:String]
                let message = aps["alert"]
                let birthdayCardFileId = userInfo["birthdayCard"] as! String
                
               showBirthdayGreeting = storyBoard.instantiateViewControllerWithIdentifier("PLShowBirthdayCardViewController") as! PLShowBirthdayCardViewController
                showBirthdayGreeting.greetingMessageFromSender = message
                showBirthdayGreeting.greetingCardId = UInt(birthdayCardFileId)
                self.window?.rootViewController = showBirthdayGreeting
                
            }
            
        }else if notificationTypeIdentifier == "PROJECT"{
            
        }
        else{
            
            //Chat screen
            
            
        }
        
         print(userInfo)
    }
    
    func chatRoomDidReceiveMessage(message: QBChatMessage, fromDialogID dialogID: String) {
       
       /* let currentViewController = UIViewController.currentViewController()
        
        if notificationBanner == nil{
            notificationBanner = AFDropdownNotification()
        }
        
       if  !QBChat.instance().isConnected(){
        
        notificationBanner.titleText = message.text
        notificationBanner.subtitleText = ""
        notificationBanner.image = UIImage(named: "chatUser.png")
        notificationBanner.topButtonText = "Open"
        notificationBanner.bottomButtonText = "Cancel"
        notificationBanner.dismissOnTap = true
        notificationBanner.presentInView(currentViewController.view, withGravityAnimation: true)

        }*/
        
    }
    
    func chatDidReceiveSystemMessage(message: QBChatMessage) {
       print("chatDidReceiveSystemMessage")
        print(message)
       
    }
    
    func presentProjectDetailViewController(selectedProjectId:String,projectName:String){
    
    if projectViewModel == nil{
        projectViewModel = PLProjectsViewModel()
    }
    
    projectViewModel.getProjectMembersList(selectedProjectId){ resultedMembers,err in
        
        print(resultedMembers)
        
        if let _ = resultedMembers{
            var navController : UINavigationController!
        if self.projectDetail == nil
        {
             self.projectDetail = self.storyBoard.instantiateViewControllerWithIdentifier("PLProjectDetailTableViewController")  as! PLProjectDetailTableViewController
             let projectDetailViewModel = PLProjectDetailViewModel(members:resultedMembers!)
             projectDetailViewModel.numberOfSections = 3
             self.projectDetail.projectId = selectedProjectId
             PLSharedManager.manager.projectId = selectedProjectId
             self.projectDetail.projectName = projectName
             self.projectDetail.projectDetailViewModel = projectDetailViewModel
             self.projectDetail.fromNotification = true
            
              navController = UINavigationController.init(rootViewController: self.projectDetail)
             self.window?.rootViewController = navController
        }
        else
        {
            print("else exe")
            navController = UINavigationController.init(rootViewController: self.projectDetail)
            self.window?.rootViewController = navController

        }
      }
    }
    
}
    

}

