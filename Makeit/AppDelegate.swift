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
class AppDelegate: UIResponder, UIApplicationDelegate,QBChatDelegate,QBRTCClientDelegate {

    var window: UIWindow?
    var reachability:Reachability!
    var notificationBanner:AFDropdownNotification!
    var showBirthdayGreeting:PLShowBirthdayCardViewController!
    var projectDetail : PLProjectDetailTableViewController!
    var projectViewModel:PLProjectsViewModel!
    var sideBarRootViewController:PLSidebarRootViewController!
    var storyBoard:UIStoryboard!
    var dialingTimer:NSTimer!
    var currentSession:QBRTCSession!
    var player:AVAudioPlayer!
 
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
       
        //Connecting Client Application with Quickblox API
        QBSettings.setApplicationID(kApplicationId)
        QBSettings.setAuthKey(kAuthorizationKey)
        QBSettings.setAuthSecret(kAuthorizationSecret)
        QBSettings.setAccountKey(kAccountKey)
        QBChat.instance().addDelegate(self)
       
        
        //QBWebRTC Config
        
        QBRTCConfig.setAnswerTimeInterval(60.0)//60
        QBRTCConfig.setDisconnectTimeInterval(30.0)//30
        QBRTCConfig.setDialingTimeInterval(5.0)//5.0
        let mediaConfig = QBRTCMediaStreamConfiguration.defaultConfiguration()
        mediaConfig.audioCodec = QBRTCAudioCodec.CodeciLBC
        QBRTCConfig.setMediaStreamConfiguration(mediaConfig)
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().addDelegate(self)
        
        //Checking Newtwork Reachability and observing Newtork changes with observer
        
        reachability = Reachability.reachabilityForInternetConnection()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.handleNetworkChanges), name:kReachabilityChangedNotification, object:nil)
      reachability.startNotifier()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let value = defaults.valueForKey("isLoggedIn")
        {
           let isLoggedIn = value as! Bool
           
            if isLoggedIn{
                
                if sideBarRootViewController == nil
                {
                 storyBoard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
                 sideBarRootViewController = storyBoard.instantiateViewControllerWithIdentifier("PLSidebarRootViewController") as! PLSidebarRootViewController
                }
                self.window?.rootViewController = sideBarRootViewController
               let  name = NSUserDefaults.standardUserDefaults().valueForKey("USER_NAME")
               let password = NSUserDefaults.standardUserDefaults().valueForKey("USER_PASSWORD")
                
                QBRequest.logInWithUserLogin(name! as! String, password: password! as! String, successBlock: { (_, _) in
               
                    }, errorBlock: { (_) in
                })
                
            }
        }
        
        
        
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
      
    }
    


    
    func presentProjectDetailViewController(selectedProjectId:String,projectName:String){
    
    if projectViewModel == nil{
        projectViewModel = PLProjectsViewModel()
    }
    
    projectViewModel.getProjectMembersList(selectedProjectId){ resultedMembers,err in
        
   
        
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
         
            navController = UINavigationController.init(rootViewController: self.projectDetail)
            self.window?.rootViewController = navController

        }
      }
    }
    
}
    
    
    func didReceiveNewSession(session: QBRTCSession!, userInfo: [NSObject : AnyObject]!) {
   
        if self.currentSession != nil{
      
            var info = Dictionary<String,String>()
            info["reject"] = "busy"
            session.rejectCall(info)
            return
        }
        self.currentSession = session
        QBRTCSoundRouter.instance().initialize()
        QBRTCSoundRouter.instance().setCurrentSoundRoute(QBRTCSoundRoute.Receiver)
        setupIncomingcall()
    }
    
    func session(session: QBRTCSession!, acceptedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        
     }
    
    func session(session: QBRTCSession!, rejectedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        
      
    }
    
    func session(session: QBRTCSession!, startedConnectingToUser userID: NSNumber!) {
        
      
    }
    
    func session(session: QBRTCSession!, connectionClosedForUser userID: NSNumber!) {
      
    }
    
    func session(session: QBRTCSession!, initializedLocalMediaStream mediaStream: QBRTCMediaStream!) {
        
        }
    
    
    func sessionDidClose(session: QBRTCSession!) {
        

        player.stop()
        self.currentSession = nil
        
    }
    
    func session(session: QBRTCSession!, updatedStatsReport report: QBRTCStatsReport!, forUserID userID: NSNumber!) {
        
        var result: String = ""
        let systemStatsFormat: String = "(cpu)%ld%%\n"
        result.appendContentsOf(String(format: systemStatsFormat, 50))
        // Connection stats.
        let connStatsFormat: String = "CN %@ms | %@->%@/%@ | (s)%@ | (r)%@\n"
        result.appendContentsOf(String(format: connStatsFormat, report.connectionRoundTripTime, report.localCandidateType, report.remoteCandidateType, report.transportType, report.connectionSendBitrate, report.connectionReceivedBitrate))
        // Audio send stats.
        let audioSendFormat: String = "AS %@ | %@\n"
        result.appendContentsOf(String(format: audioSendFormat, report.audioSendBitrate, report.audioSendCodec))
        
        // Audio receive stats.
        let audioReceiveFormat: String = "AR %@ | %@ | %@ms | (expandrate)%@"
        result.appendContentsOf(String(format: audioReceiveFormat, report.audioReceivedBitrate, report.audioReceivedCodec, report.audioReceivedCurrentDelay, report.audioReceivedExpandRate))
        
        
    }

 
    
    
    func setupIncomingcall(){
        
        startDialingTone()
        let viewController = UIViewController.currentViewController()
         self.showAlertWithMessage("\(PLSharedManager.manager.userName) is calling", message: "", controller:viewController)
        
    }
    
    func startDialingTone(){
        
        //JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        //QMSoundManager.playRingtoneSound()
        
        let soundFilePath: String = NSBundle.mainBundle().pathForResource("ringtone", ofType:"mp3")!
        let soundFileURL: NSURL = NSURL.fileURLWithPath(soundFilePath)
        player = try! AVAudioPlayer(contentsOfURL: soundFileURL)
        player.numberOfLoops = -1
        player.play()
    }

    func showAlertWithMessage(title:String,message:String,controller : UIViewController)
    {
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
            let accept = UIAlertAction(title:"Accept", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                print("call accepted")
                self.player.stop()
                self.currentSession.acceptCall(nil)
            })
            
            let reject = UIAlertAction(title:"Reject", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                print("call rejected")
                self.player.stop()
                self.currentSession.rejectCall(nil)
                
            })
            
            alertController.addAction(accept)
            alertController.addAction(reject)
            controller.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
         
            
//            let alert = UIAlertView(title: title, message: message, delegate:nil, cancelButtonTitle:"Ok", otherButtonTitles:"") as UIAlertView
//            alert.show()
    
        }
    }


}



