//
//  PLSidebarMenuViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 10/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Social

class PLSidebarMenuViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var userProfilePic: UIImageView!
    
    @IBOutlet var userNameTextfield: UILabel!
    
    @IBOutlet weak var sideBarTableView: UITableView!
    
    var projectViewModel:PLProjectsViewModel = PLProjectsViewModel()
    var tapGestureRecognizer : UITapGestureRecognizer?
    var imagePicker = UIImagePickerController()
    var taskList = [String]()
    var settingsList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskList.append("Todays Tasks")
        taskList.append("UpComing Tasks")
        taskList.append("Pending Tasks")
        settingsList.append("Logout")
        imagePicker.delegate = self
        tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(PLSidebarMenuViewController.editUserProfilePicture))
        self.userProfilePic.userInteractionEnabled = true
        self.userProfilePic.addGestureRecognizer(tapGestureRecognizer!)
        tapGestureRecognizer?.numberOfTapsRequired = 1
        tapGestureRecognizer?.numberOfTouchesRequired = 1

        userProfilePic.layer.cornerRadius = 35.0
        userProfilePic.layer.masksToBounds = true
        projectViewModel.fetchUserAvatar(){[weak self] avatar in
         
         if avatar != nil{
         self!.userProfilePic.image = avatar!
         }
         else{
               self!.userProfilePic.image = UIImage(named:"chatUser.png")
            }
         }
        self.userNameTextfield.text = "\(PLSharedManager.manager.userName.uppercaseString)"
      }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0
        {
            return "Tasks"
        }
        else if section == 1
        {
            return "Settings"
        }
        else
        {
            return ""
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
          return taskList.count
        }
        else if section == 1
        {
            return settingsList.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        cell?.accessoryType = .DisclosureIndicator
        if indexPath.section == 0
        {
        cell?.textLabel?.text = taskList[indexPath.row]
        }
        else if indexPath.section == 1
        {
            cell?.textLabel?.text = settingsList[indexPath.row]
        }
       
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1
        {
            //self.projectViewModel.performLogout()
            print("Logout Action")
            var signUpViewController : PLUserLoginViewController? = self.storyboard?.instantiateViewControllerWithIdentifier("PLUserSignupAndLoginViewController") as? PLUserLoginViewController
          self.presentViewController(signUpViewController!, animated: true, completion: nil)
          signUpViewController = nil
        }
    }
    
    
    func editUserProfilePicture()
    {
        print("edit profile")
        if #available(iOS 8.0, *) {
            
            let attributedString = NSAttributedString(string: "Edit Photo", attributes: [
                NSFontAttributeName : UIFont.systemFontOfSize(20) ,
                NSForegroundColorAttributeName : UIColor.blackColor()
                ])
            let alertContrl = UIAlertController(title: "" , message:"", preferredStyle: UIAlertControllerStyle.ActionSheet)
            alertContrl.setValue(attributedString, forKey: "attributedTitle")
            let photoGallery = UIAlertAction.init(title: "Photo Library", style: UIAlertActionStyle.Default) { (action : UIAlertAction) in
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .PhotoLibrary
                self.imagePicker.modalPresentationStyle = .Popover
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            
            let takePhoto = UIAlertAction.init(title: "Take Photo", style: UIAlertActionStyle.Default) { (action : UIAlertAction) in
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .Camera
                self.imagePicker.modalPresentationStyle = .Popover
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            
            let sharePhotoOnFacebook = UIAlertAction.init(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (action : UIAlertAction) in
      
                if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
                {
                    let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                    composeViewController.addImage(self.userProfilePic.image)
                    self.presentViewController(composeViewController, animated: true, completion: nil)

                }
                else{
                    print("You are not logged in to your Facebook account")
                }
            }
            
            let sharePhotoOnTwitter = UIAlertAction.init(title: "Share on Twitter", style: UIAlertActionStyle.Default) { (action : UIAlertAction) in
                
                if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
                {
                    let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                    composeViewController.addImage(self.userProfilePic.image)
                    self.presentViewController(composeViewController, animated: true, completion: nil)
                }
                    
                else{
                    print("You are not logged in to your Twitter account")
                }
            }
        
            let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action : UIAlertAction) in
        
            }
           
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera ) == true
            {
                alertContrl.addAction(takePhoto)
            }
            else{
                print("Camera is not Supported")
            }
            alertContrl.addAction(photoGallery)
            alertContrl.addAction(sharePhotoOnFacebook)
            alertContrl.addAction(sharePhotoOnTwitter)
            alertContrl.addAction(cancelAction)
            self.presentViewController(alertContrl, animated: true, completion: nil)
            }
            
         else
         {
            // Fallback on earlier versions
         }
       
     }
 
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let img =  info[UIImagePickerControllerOriginalImage] as! UIImage
        userProfilePic.image = img
        var capturedImage = resizeImage(img, width: 4.0, height: 4.0)
        SVProgressHUD.showWithStatus("Uploading")
        projectViewModel.updateUserAvatar(capturedImage){[weak self] result in
         if result{print("Succesfully uploaded"); SVProgressHUD.dismiss();
         capturedImage = self!.resizeImage(capturedImage, width: 4.0, height: 4.0)
        
         }
         else{print("Error!");SVProgressHUD.dismiss()}
         }

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        print("Cancelled")
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    func resizeImage(image:UIImage,width:CGFloat,height:CGFloat)->UIImage
    {
        let rect = CGRectMake(0, 0, image.size.width/width, image.size.height/height)
        UIGraphicsBeginImageContext(rect.size)
        image.drawInRect(rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let compressedImageData = UIImageJPEGRepresentation(resizedImage, 0.1)
        let image =  UIImage(data:compressedImageData!)!
        
        return maskRoundedImage(image, radius: 12)
        
    }
    
    func maskRoundedImage(image: UIImage, radius: Float) -> UIImage {
        let imageView: UIImageView = UIImageView(image: image)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(radius)
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }

}
