//
//  AppDelegate.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 12/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//  Project Light is the confidential initiation for Makeit Project.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability:Reachability!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
       
        //Connecting Client Application with Quickblox API
        QBSettings.setApplicationID(kApplicationId)
        QBSettings.setAuthKey(kAuthorizationKey)
        QBSettings.setAuthSecret(kAuthorizationSecret)
        QBSettings.setAccountKey(kAccountKey)
        
        //Checking Newtwork Reachability and observing Newtork changes with observer
        
        reachability = Reachability.reachabilityForInternetConnection()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("handleNewtorkChanges"), name:kReachabilityChangedNotification, object:nil)
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
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func handleNewtorkChanges(){
        
        let remoteHost = reachability.currentReachabilityStatus() as NetworkStatus
        if remoteHost == NotReachable
        {
            //Handle when Network is disconnected
            print("Not Reachable")
        }
        else
        {
           //Handle when newtwok gets connected
        }
    }

}

