//
//  PLSidebarMenuViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 10/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLSidebarMenuViewController: UIViewController {
    
    @IBOutlet var userProfilePic: UIImageView!
    
    @IBOutlet var userNameTextfield: UILabel!
    
    var projectViewModel:PLProjectsViewModel = PLProjectsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfilePic.layer.cornerRadius = 25.0
        userProfilePic.layer.masksToBounds = true
        projectViewModel.fetchUserAvatar(){[weak self] avatar in
         
         if avatar != nil{
         self!.userProfilePic.image = avatar!
         }
         else{
               self!.userProfilePic.image = UIImage(named:"chatUser.png")
            }
         }
        self.userNameTextfield.text = "Hi! \(PLSharedManager.manager.userName)"
      }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
