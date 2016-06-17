//
//  PLProjectsViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 16/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox


class PLProjectsViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PopupDelegate,RefreshProjectsDataSource {
    
    @IBOutlet var projectTableView: UITableView!
    var selectedProjectId:String?
    var selectedProjectName:String!
    var selectedProjectDescription:String!
    var selectedProejctCreatorId:UInt!
    var addProjectViewController:PLAddProjectViewController?
    var projectViewModel:PLProjectsViewModel!
    var activityIndicatorView:UIActivityIndicatorView!
    var animateCell:[Bool] = [Bool]()
    var observerContext = 0
    var profilePicSettings:UIBarButtonItem!
    var plPhotoPickerController:UIImagePickerController!
    var userProfileController : PLUserProfileInfoTableViewController?
    var editProjectButton:UIBarButtonItem!
    var selectedSection:Int!
    var fetchDataFlag = false

  override func viewDidLoad() {
        super.viewDidLoad()
    
    self.projectTableView.registerNib(UINib(nibName:"PLProjectViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier: "ProjectCell")
         self.projectTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
    func animateTable() {
        projectTableView.reloadData()
        
        let cells = self.projectTableView.visibleCells
        let tableHeight: CGFloat = projectTableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0);
                }, completion: nil)
            
            index += 1
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
        
        if fetchDataFlag == false
        {
          projectViewModel.addObserver(self, forKeyPath:"createdProjectList", options: NSKeyValueObservingOptions.New, context:&observerContext)
          addActivityIndicatorView()
          projectViewModel.fetchProjectsFromServer()
        }
        else
        {
            animateTable()
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
      
        let sidebarImage = UIImage(named: "sideBar.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        profilePicSettings = UIBarButtonItem(image:sidebarImage, style: UIBarButtonItemStyle.Plain, target:self , action: #selector(PLProjectsViewController.showSettingsActionSheet))
       self.navigationItem.leftBarButtonItem = profilePicSettings
    }
    
    func showSettingsActionSheet()
    {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    func addNewProject()
    {
        let addProjectButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(PLProjectsViewController.addNewProjectToList))
         editProjectButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PLProjectsViewController.deleteProjectInList))
        self.navigationItem.rightBarButtonItems = [addProjectButton,editProjectButton]
       
    }
    
    func addNewProjectToList()
    {
       
        if addProjectViewController == nil{
           addProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLAddProjectViewController") as? PLAddProjectViewController
        }
        fetchDataFlag = true
        addProjectViewController!.delegate = self
        self.navigationController?.pushViewController(addProjectViewController!, animated: true)
        if observerContext == 0 {projectViewModel.removeObserver(self, forKeyPath:"createdProjectList")}
        
    }
    
    func deleteProjectInList(){
        if editProjectButton.title == "Edit"{
            editProjectButton.title = "Done"
            self.projectTableView.setEditing(true, animated: true)
        }else{
            
            editProjectButton.title = "Edit"
            self.projectTableView.setEditing(false, animated: true)
        }
    }
   
    
   //MARK: UITableView DataSource
    
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int
   {
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
    
   override  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
   {
        
            if indexPath.section == 0
            {
            let cell = tableView.dequeueReusableCellWithIdentifier("ProjectCell")! as! PLProjectViewCell
            cell.projectName?.text = projectViewModel.ProjectTitle(indexPath.row)
            cell.projectName?.textColor = UIColor.blackColor()
            cell.projectDescription?.text = projectViewModel.subTitle(indexPath.row)
            cell.circularView.backgroundColor = projectViewModel.getViewColor()
            cell.projectLetterLabel.text = String(projectViewModel.projectNameStartLetter(indexPath.row, section: indexPath.section))
            cell.projectLetterLabel.textColor = UIColor.whiteColor()
            cell.createdAt.text = "Created At :" + " " + projectViewModel.projectCreatedDate(indexPath.row,section: indexPath.section)
            cell.createdBy.text = "Created by : You"
            cell.accessoryType = .DisclosureIndicator
            return cell
            }
          if indexPath.section == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("ProjectCell")! as! PLProjectViewCell
              cell.projectName?.text = projectViewModel.contributingProjectTitle(indexPath.row)
              cell.projectName?.textColor = UIColor.blackColor()
              cell.projectDescription?.text = projectViewModel.contributingProjectSubTitle(indexPath.row)
              cell.circularView.backgroundColor = projectViewModel.getViewColor()
              cell.createdAt.text  = "Created At :" + " " + projectViewModel.projectCreatedDate(indexPath.row,section: indexPath.section)
              cell.projectLetterLabel.text =  String(projectViewModel.projectNameStartLetter(indexPath.row, section: indexPath.section))
              cell.projectLetterLabel.textColor = UIColor.whiteColor()
              cell.createdBy.text = projectViewModel.projectCreator(indexPath.row)
              cell.accessoryType = .DisclosureIndicator
              return cell
            }
    
         if indexPath.section == 2{
             let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
             cell.textLabel?.text = "Improve Your Profile"
             cell.textLabel?.textColor = enableButtonColor
             cell.detailTextLabel?.text = ""
            return cell
            }
        return UITableViewCell()
    }
    
   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
   {
        if indexPath.section == 2
        {
            return 40
        }
        return 100
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var titleForHeader:String = ""
        
        if section == 0{
            titleForHeader = "  Created Projects"
            return headerViewForTableView(titleForHeader)
        }
        else if section == 1
        {
            titleForHeader = "  Contributing Projects"
             return headerViewForTableView(titleForHeader)
        }
        else if section == 2{
             let name = QBSession.currentSession().currentUser?.fullName
             titleForHeader = "  Hi \(name!) ! Love to improve profile"
             return headerViewForTableView(titleForHeader)
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
        fetchDataFlag = true
        if indexPath.section == 2{
      
            
            self.userProfileController = self.storyboard?.instantiateViewControllerWithIdentifier("PLUserProfileInfoTableViewController") as? PLUserProfileInfoTableViewController
            self.userProfileController?.disablingBtn = true
            self.navigationController?.pushViewController(self.userProfileController!, animated: true)
            
        }
        else
        {
        let selected = projectViewModel.didSelectRow(indexPath.row,section:indexPath.section) as PLProject
        PLSharedManager.manager.projectName = selected.name
        PLSharedManager.manager.projectId = selected.projectId!
        selectedProjectId = selected.projectId
        selectedProjectName = selected.name
        selectedProjectDescription = selected.subTitle
        selectedProejctCreatorId = selected.createdBy
        selectedSection = indexPath.section
        PLSharedManager.manager.projectCreatedByUserId = selected.createdBy
        projectViewModel.getProjectMembersList(selectedProjectId!){ resultedMembers,err in
            
            print(resultedMembers)
            
            if let _ = resultedMembers{
                
              self.performSegueWithIdentifier("toProjectDetails", sender: resultedMembers)
            }
            else
            {
                PLSharedManager.showAlertIn(self, error: err!, title: "Error occured while fetching project member list", message: err.debugDescription)
            }
        }
     }
   }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle:
        UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        func deleteProject(){
            
            activityIndicatorView.startAnimating()
            self.projectTableView.backgroundColor = UIColor(red:235/255, green: 235/255, blue: 241/255, alpha: 1)
            projectViewModel.deleteProjectInParticularRow(indexPath.row){[weak self] result,err in
                
                if result{
                    self!.activityIndicatorView.stopAnimating()
                    self!.projectViewModel.createdProjectList.removeAtIndex(indexPath.row)
                    self!.projectTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
                }
                else
                {
                      self!.activityIndicatorView.stopAnimating()
                    PLSharedManager.showAlertIn(self!, error: err!, title: "Error occured while deleting the project in a particulare row", message: err.debugDescription)
                }
                
            }
        }

        
        if indexPath.section == 0{
            if editingStyle == .Delete
                 {
                    presentPopup(deleteProject)
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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        if keyPath == "createdProjectList"
        {    if projectViewModel.rowsCount() > 0 || projectViewModel.contributingProjectsRowCount() > 0
          {
            for _ in 0...projectViewModel.rowsCount(){ animateCell.append(false)}
            activityIndicatorView.stopAnimating()
            projectTableView.reloadData()
            animateTable()
            projectViewModel.removeObserver(self, forKeyPath:"createdProjectList")
            observerContext = 1
        } else{ activityIndicatorView.stopAnimating() }
        }
        
    }
    
    func headerViewForTableView(title:String)->UILabel{
        
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
        detailViewController.projectCreatedBy = selectedProejctCreatorId
        detailViewController.projectDescription = selectedProjectDescription
        detailViewController.fromNotification = false
        let projectDetailViewModel = PLProjectDetailViewModel(members:resulted)
        if let _ = selectedSection{
            projectDetailViewModel.numberOfSections = selectedSection!
        }
        detailViewController.projectDetailViewModel = projectDetailViewModel
    }
  
    //Show Alert Popup
    func presentPopup(delete:()->Void){
        
        let projectDeletePopup = Popup(title:"Are you sure delete this Project?", subTitle: "Deleting Project will erase all of its data.This data cannot be recovered.", textFieldPlaceholders:[], cancelTitle:"Cancel", successTitle: "Delete", cancelBlock: {
            
            }, successBlock: {
                
                delete()
        })
       
        projectDeletePopup.delegate = self
        projectDeletePopup.titleColor = UIColor.redColor()
        projectDeletePopup.backgroundBlurType = .Dark
        projectDeletePopup.roundedCorners = true
        projectDeletePopup.tapBackgroundToDismiss = true
        projectDeletePopup.swipeToDismiss = true
        projectDeletePopup.successBtnColor = UIColor.redColor()
        projectDeletePopup.cancelBtnColor = UIColor(red:86/255, green: 102/255, blue: 159/255, alpha: 1)
        projectDeletePopup.showPopup()

    }
  
    func addProjectToDataSource(project: PLProject)
    {
        
        projectViewModel.addNewProjectToCreatedProjectList(project){ res in
            self.projectTableView.reloadData()
        }
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


