//
//  PLProjectsViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 16/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox


class PLProjectsViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet var projectTableView: UITableView!
    var selectedProjectId:String?
    var selectedProjectName:String!
    var selectedProjectDescription:String!
    var addProjectViewController:PLAddProjectViewController?
    var projectViewModel:PLProjectsViewModel!
    var activityIndicatorView:UIActivityIndicatorView!
    var animateCell:[Bool] = [Bool]()
    var observerContext = 0
    var profilePicSettings:UIBarButtonItem!
    var profilePicSettingsCustomView:UIButton!
    var plPhotoPickerController:UIImagePickerController!

  override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Projects"
        addLogoutBarButtonItem()
        addNewProject()
       projectViewModel = PLProjectsViewModel()
       print(QBSession.currentSession().currentUser?.customData)
    
     let user = QBUUser()
     user.ID = (QBSession.currentSession().currentUser?.ID)!
     user.password = PLSharedManager.manager.userPassword
    
      QBChat.instance().connectWithUser(user) { (error: NSError?) -> Void in
        if error == nil{
            print("Success in connection")
         }
      }

    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
        //projectViewModel = PLProjectsViewModel()
        projectViewModel.addObserver(self, forKeyPath:"createdProjectList", options: NSKeyValueObservingOptions.New, context:&observerContext)
        projectViewModel.fetchProjectsFromRemote()
        addActivityIndicatorView()
        projectViewModel.fetchUserAvatar(){[weak self] avatar in
            
            if avatar != nil{
                self!.profilePicSettingsCustomView.setBackgroundImage(avatar!, forState: .Normal)
            }
            else{self!.profilePicSettingsCustomView.setBackgroundImage(UIImage(named:"UserImage.png"), forState: .Normal)}
        }

    }
    
    func  addActivityIndicatorView() {
        if activityIndicatorView == nil{
            
          activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.hidesWhenStopped = true
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
        }
    }
    
    func addLogoutBarButtonItem(){
       
       profilePicSettingsCustomView = UIButton(type: .Custom)
       profilePicSettingsCustomView.frame = CGRectMake(0, 0, 30, 30)
       profilePicSettingsCustomView.layer.cornerRadius = 15.0
       profilePicSettingsCustomView.addTarget(self, action:#selector(PLProjectsViewController.showSettingsActionSheet), forControlEvents: UIControlEvents.TouchUpInside)
       profilePicSettingsCustomView.setBackgroundImage(UIImage(named:"UserImage.png"), forState: UIControlState.Normal)
       profilePicSettings = UIBarButtonItem(customView:profilePicSettingsCustomView)
 
       self.navigationItem.leftBarButtonItem = profilePicSettings
    }
    
    func showSettingsActionSheet()
    {
        
        if #available(iOS 8.0, *) {
            let settingsActionSheet = UIAlertController(title:"Upload Profile", message:"", preferredStyle: UIAlertControllerStyle.ActionSheet)
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Library", style: UIAlertActionStyle.Default, handler: {[weak self] (action) in
                
                if self!.plPhotoPickerController == nil
                {
                    self!.plPhotoPickerController = UIImagePickerController()
                    self!.plPhotoPickerController.delegate = self
                }
                self!.plPhotoPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self!.plPhotoPickerController.allowsEditing = true
                
                self?.navigationController?.presentViewController(self!.plPhotoPickerController, animated: true, completion:nil)
                
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Camera", style: UIAlertActionStyle.Default, handler: {[weak self] (action) in
                if self!.plPhotoPickerController == nil
                {
                    self!.plPhotoPickerController = UIImagePickerController()
                    self!.plPhotoPickerController.delegate = self

                }
                 self!.plPhotoPickerController.sourceType = UIImagePickerControllerSourceType.Camera
                 self!.plPhotoPickerController.allowsEditing = true
                 //self?.navigationController?.presentViewController(self!.plPhotoPickerController, animated: true, completion:nil)
            }))

          
            
            settingsActionSheet.addAction(UIAlertAction(title:"Logout", style: UIAlertActionStyle.Default, handler: {[weak self] (action) in
                
                 if self!.observerContext == 0 {self!.projectViewModel.removeObserver(self!, forKeyPath:"createdProjectList")}
                 self!.projectViewModel.performLogout()
                 self!.projectTableView.reloadData()
                 self!.navigationController?.popToRootViewControllerAnimated(true)

            }))
            
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) in
                
                print("Cancel")
            }))

           if UIDevice.currentDevice().userInterfaceIdiom == .Pad
           {
             let alertPopoverPresentationController = settingsActionSheet.popoverPresentationController;
             let source = profilePicSettings.valueForKey("view")
             alertPopoverPresentationController!.sourceRect = (source?.frame)!
             alertPopoverPresentationController!.sourceView = self.view;
           }
            
            self.presentViewController(settingsActionSheet, animated: true, completion:nil)
            
        } else {
            // Fallback on earlier versions
            
        }
    }
    
    func addNewProject()
    {
        
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(PLProjectsViewController.addNewProjectToList))
    }
    
    func addNewProjectToList()
    {
        
        if addProjectViewController == nil{
           addProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLAddProjectViewController") as? PLAddProjectViewController
        }
        self.navigationController?.pushViewController(addProjectViewController!, animated: true)
        if observerContext == 0 {projectViewModel.removeObserver(self, forKeyPath:"createdProjectList")}
    }
    
   //MARK: UITableView DataSource
    
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
             return projectViewModel.rowsCount()
        }
        else if section == 1{
            
            return projectViewModel.contributingProjectsRowCount()
        }
        
        else if section == 2{
            
            return 1
        }
    
        return 0
    }
    
   override  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
            if indexPath.section == 0
            {
            cell.textLabel?.text = projectViewModel.titleAtIndexPath(indexPath.row)
             cell.textLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.text = projectViewModel.subTitleAtIndexPath(indexPath.row)
            }
          if indexPath.section == 1{
              cell.textLabel?.text = projectViewModel.contributingProjectTitleAtIndexPath(indexPath.row)
              cell.textLabel?.textColor = UIColor.blackColor()
              cell.detailTextLabel?.text = projectViewModel.contributingProjectSubTitleAtIndexPath(indexPath.row)
            }
    
         if indexPath.section == 2{
        
             cell.textLabel?.text = "Improve Profile"
             cell.textLabel?.textColor = enableButtonColor
             cell.detailTextLabel?.text = ""
            }
        return cell
    }
    

    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var titleForHeader:String = ""
        
        if section == 0{
            titleForHeader = "  Created Projects"
            return hedaerViewForTableView(titleForHeader)
        }
        else if section == 1
        {
            titleForHeader = "  Contributing Projects"
             return hedaerViewForTableView(titleForHeader)
        }
        else if section == 2{
             let name = QBSession.currentSession().currentUser?.fullName
             titleForHeader = "  Hi \(name!) ! Love to improve profile"
             return hedaerViewForTableView(titleForHeader)
        }

        return nil
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if section == 2{
            
            let titleForFooter = "By improving your profile, you will make yourself more closer to other Makeit users."

            return titleForFooter
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 2{
            
            print("Improve Profile ViewController")
            
        }else if indexPath.section == 0 || indexPath.section == 1{
            let selected = projectViewModel.didSelectRowAtIndex(indexPath.row,section:indexPath.section) as PLProject
        PLSharedManager.manager.projectName = selected.name
        PLSharedManager.manager.projectId = selected.projectId!
        selectedProjectId = selected.projectId
        selectedProjectName = selected.name
        selectedProjectDescription = selected.subTitle
        projectViewModel.getProjectMembersList(selectedProjectId!){ resultedMembers in
            
            if let _ = resultedMembers{
                
              self.performSegueWithIdentifier("toProjectDetails", sender: resultedMembers)
            }
        }
        }
       }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle:
        UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0{
        if editingStyle == .Delete
        {
            activityIndicatorView.startAnimating()
            projectViewModel.deleteProjectAtIndexPathOfRow(indexPath.row){[weak self] result in
                
                if result{
                    self!.activityIndicatorView.stopAnimating()
                    self!.projectViewModel.createdProjectList.removeAtIndex(indexPath.row)
                    self!.projectTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
                }
            
            }
        }
      }
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0{
            return true
     }
        return false
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0
        {
        if !animateCell[indexPath.row]
        {
            let transformRotate = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
            cell.layer.transform = transformRotate
            UIView.animateWithDuration(0.3) {
                
                cell.layer.transform = CATransform3DIdentity
            }
        }
        animateCell[indexPath.row] = true
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "createdProjectList"
        {    if projectViewModel.rowsCount() > 0 || projectViewModel.contributingProjectsRowCount() > 0
          {
            for _ in 0...projectViewModel.rowsCount(){ animateCell.append(false)}
            activityIndicatorView.stopAnimating()
            projectTableView.reloadData()
            projectViewModel.removeObserver(self, forKeyPath:"createdProjectList")
            observerContext = 1
        } else{ activityIndicatorView.stopAnimating() }
        }
        
    }
    
    func hedaerViewForTableView(title:String)->UILabel{
        
        let titleLabel = UILabel(frame:CGRectMake(0,0,self.view.frame.size.width,40))
        titleLabel.text = title
        titleLabel.backgroundColor = UIColor.lightTextColor()
        titleLabel.textAlignment = .Left
        titleLabel.font = UIFont.systemFontOfSize(15)
    
        return titleLabel
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let resulted = sender as! [PLTeamMember]
        let detailViewController = segue.destinationViewController as! PLProjectDetailTableViewController
        detailViewController.projectName = selectedProjectName
        detailViewController.projectId = selectedProjectId
        detailViewController.projectDescription = selectedProjectDescription
        let projectDetailViewModel = PLProjectDetailViewModel(members:resulted)
        detailViewController.projectDetailViewModel = projectDetailViewModel
    }
  
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var capturedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        capturedImage = resizeImage(capturedImage, width: 4.0, height: 4.0)
        SVProgressHUD.showWithStatus("Uploading")
          projectViewModel.updateUserAvatar(capturedImage){[weak self] result in
            if result{print("Succesfully uploaded"); SVProgressHUD.dismiss();
                capturedImage = self!.resizeImage(capturedImage, width: 4.0, height: 4.0)
                let buttonView = self?.profilePicSettings.valueForKey("view") as! UIView
                buttonView.layer.cornerRadius = 10
                self!.profilePicSettingsCustomView.setBackgroundImage(capturedImage, forState: UIControlState.Normal)
            }
            else{print("Error!");SVProgressHUD.dismiss()}
        }
        
        picker.dismissViewControllerAnimated(true, completion:nil)
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


extension UIViewController{
    
    class func currentViewController()->UIViewController{
        
        let controller = UIApplication.sharedApplication().keyWindow?.rootViewController
        return UIViewController.findCurrentViewController(controller!)
    }
    
    
    class func findCurrentViewController(controller:UIViewController)->UIViewController{
        
        if (controller.presentedViewController != nil){
            
            return UIViewController.findCurrentViewController(controller.presentedViewController!)
        }
        else if controller is UISplitViewController{
            
           let split = controller as! UISplitViewController
            
            if split.viewControllers.count > 0{
                
                return UIViewController.findCurrentViewController(split.viewControllers.last!)
            }
            else{
                
                return controller
            }
            
        }
        
        else if controller is UINavigationController{
            
            let nav = controller as! UINavigationController
            
            if nav.viewControllers.count > 0{
                
                
                return UIViewController.findCurrentViewController(nav.topViewController!)
            }
            else{
                return controller
            }
        }
        
        else if controller is UITabBarController{
           
            let tab = controller as! UITabBarController
            
            if tab.viewControllers?.count > 0{
                
                return UIViewController.findCurrentViewController(tab.selectedViewController!)
            }
            else{
                return controller
            }
            
            
        }
        else{
            
            return controller
        }
    }
    
}


