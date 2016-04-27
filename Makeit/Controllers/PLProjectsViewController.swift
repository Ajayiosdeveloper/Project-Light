//
//  PLProjectsViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 16/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit


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
       projectViewModel.fetchUserAvatar(){[weak self] avatar in
        
        if avatar != nil{
            self!.profilePicSettingsCustomView.setBackgroundImage(avatar!, forState: .Normal)
        }
        else{self!.profilePicSettingsCustomView.setBackgroundImage(UIImage(named:"UserImage.png"), forState: .Normal)}
    }

      print(NSUserDefaults.standardUserDefaults().objectForKey("AVATAR_ID"))
    
}
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
        //projectViewModel = PLProjectsViewModel()
        projectViewModel.addObserver(self, forKeyPath:"projectList", options: NSKeyValueObservingOptions.New, context:&observerContext)
        projectViewModel.fetchProjectsFromRemote()
        addActivityIndicatorView()
       
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
                
                 if self!.observerContext == 0 {self!.projectViewModel.removeObserver(self!, forKeyPath:"projectList")}
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
        if observerContext == 0 {projectViewModel.removeObserver(self, forKeyPath:"projectList")}
    }
    
   //MARK: UITableView DataSource
    
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return projectViewModel.rowsCount()
    
    }
    
   override  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
            cell.textLabel?.text = projectViewModel.titleAtIndexPath(indexPath.row)
            cell.detailTextLabel?.text = projectViewModel.subTitleAtIndexPath(indexPath.row)
        return cell
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selected = projectViewModel.didSelectRowAtIndex(indexPath.row) as PLProject
        PLSharedManager.manager.projectName = selected.name
        selectedProjectId = selected.projectId
        selectedProjectName = selected.name
        selectedProjectDescription = selected.subTitle
        print(selected.name)
        print(selected.subTitle)
        print(selected.createdBy)
        print(selected.projectId)
        print(selected.parentId)
        
        projectViewModel.getProjectMembersList(selectedProjectId!){ resultedMembers in
            
            if let _ = resultedMembers{
                
              self.performSegueWithIdentifier("toProjectDetails", sender: resultedMembers)
            }
        }
       
        
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle:
        UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            activityIndicatorView.startAnimating()
            projectViewModel.deleteProjectAtIndexPathOfRow(indexPath.row){[weak self] result in
                
                if result{
                    self!.activityIndicatorView.stopAnimating()
                    self!.projectViewModel.projectList.removeAtIndex(indexPath.row)
                    self!.projectTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
                }
            
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "projectList"
        {    if projectViewModel.rowsCount() > 0
          {
            for _ in 0...projectViewModel.rowsCount(){ animateCell.append(false)}
            activityIndicatorView.stopAnimating()
            projectTableView.reloadData()
            projectViewModel.removeObserver(self, forKeyPath:"projectList")
            observerContext = 1
        } else{ activityIndicatorView.stopAnimating() }
        }
        
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
        projectViewModel.uploadUserAvatar(capturedImage){[weak self] result in
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
