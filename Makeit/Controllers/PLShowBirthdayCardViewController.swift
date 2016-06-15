//
//  PLShowBirthdayCardViewController.swift
//  Makeit
//
//  Created by Tharani P on 15/06/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLShowBirthdayCardViewController: UIViewController {

    @IBOutlet var greetingMessage: UILabel!
    
    @IBOutlet var greetingCardImageView: UIImageView!
    
    @IBOutlet var headerBarItem: UINavigationItem!
  
    
    
    var greetingCardId:UInt!
    
    var greetingMessageFromSender:String!
   
    var sideBarRootViewController:PLSidebarRootViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let components = greetingMessageFromSender.componentsSeparatedByString(" ")
        if components.count > 0{
             headerBarItem.title = "Greetings from \(components.last!)"
        }else{
            headerBarItem.title = "Birthday Greetings"
        }
       
        greetingMessage.text = greetingMessageFromSender
        SVProgressHUD.showWithStatus("Loading")
        QBRequest.downloadFileWithID(greetingCardId, successBlock: { (_, imageData) in
            SVProgressHUD.dismiss()
            let image = UIImage(data:imageData)
            self.greetingCardImageView.image = image!
            
            }, statusBlock: { (_, _) in
                
        }) { (_) in
            SVProgressHUD.dismiss()
            print("Error occured")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showHomeViewController(sender: AnyObject) {
        
        presentProjectsViewController()
        
    }

    func presentProjectsViewController(){
        
        if (sideBarRootViewController == nil)
        {
            sideBarRootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLSidebarRootViewController") as! PLSidebarRootViewController
        }
        self.presentViewController(sideBarRootViewController, animated: true, completion:nil)
    }
    


}
