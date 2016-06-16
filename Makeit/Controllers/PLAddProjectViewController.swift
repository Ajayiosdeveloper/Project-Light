//
//  PLAddProjectViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 18/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox
protocol RefreshProjectsDataSource:class{
    
    func addProjectToDataSource(project:PLProject)
}

class PLAddProjectViewController: UIViewController,UISearchBarDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,PLContributorTableViewDelegate,ProjectDetailsDelegate,UIAlertViewDelegate {
    
    @IBOutlet var projectName: UITextField!
    @IBOutlet var projectDescription: UITextField!
    @IBOutlet var contributorsSearchField: UISearchBar!
    var  diplayMembersPopover:PLDisplayMembersPopover!
    var activityIndicatorView:UIActivityIndicatorView!
    var teamMemberViewModel:PLTeamMemberModelView!
    var projectDetails:[String]!
    var projectDetailViewModel:PLProjectDetailViewModel!
    var plPopOverController:WYPopoverController?
    weak var delegate:RefreshProjectsDataSource? = nil
    @IBOutlet var popoverbutton: UIButton!
    @IBOutlet var contributorsTableView: UITableView!
   
    
    lazy var addProjectViewModel:PLAddProjectViewModel = {
     
        return PLAddProjectViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneBarButtonItem()
        projectName.delegate = self
        self.contributorsTableView.registerNib(UINib(nibName:"PLTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier: "Cell")
         addActivityIndicatorView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.projectName.becomeFirstResponder()
       
        if let _ = projectDetails
        {
            self.projectName.text = projectDetails![1]
            self.projectName.userInteractionEnabled = false
            self.projectDescription.text = projectDetails![2]
            self.projectDescription.userInteractionEnabled = false
            self.contributorsSearchField.prompt = "Add Contributors to \(self.projectName.text!)"
       }
    }
    
    func  addActivityIndicatorView() {
        if activityIndicatorView == nil{
            
            activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.hidesWhenStopped = true
            self.view.addSubview(activityIndicatorView)
           }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func addDoneBarButtonItem(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target:self, action:#selector(PLAddProjectViewController.performDone))
    }
   
    func isAddedContributor() -> Bool
    {
        if addProjectViewModel.selectedContributors.count == 0
        {
            activityIndicatorView.stopAnimating()
            showAlertWithMessage("Add Contributor", message: "You must have to select atleast one contributor for a project")
            return false
        }
        
        return true
    }

    
    func performDone()
    {
        activityIndicatorView.startAnimating()
        
        if projectDetails == nil{
        if addProjectViewModel.validateProjectDetails(projectName.text!){
            if isAddedContributor()
            {
            addProjectViewModel.createNewProjectWith(projectName.text!,description:projectDescription.text!){[weak self]project in
                if let _ = project{
                    self!.delegate?.addProjectToDataSource(project!)
                    self!.navigationController?.popViewControllerAnimated(true)
                    self!.cleanUp()

                }
             }
            }
          }
        }
        else{
            
            addProjectViewModel.addContributorsToExistingProject(projectDetails![0],des: projectDescription.text!){[weak self] members in
                self!.projectDetailViewModel.contributors.appendContentsOf(members)
                self!.navigationController?.popViewControllerAnimated(true)
                self!.cleanUp()

            }
        }
    }
   
    func showAlertWithMessage(title:String,message:String)
    {
        if #available(iOS 8, *)
        {
            let alertController = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            alertController.addAction(action)
            self.presentViewController(alertController, animated:true, completion:nil)
        }
        else{
            let alert = UIAlertView(title: title, message: message, delegate:self, cancelButtonTitle:nil, otherButtonTitles:"Ok") as UIAlertView
            alert.show()
        }
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        contributorsSearchField.prompt = "Add contributors to \(newString)"
       return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == projectDescription
        {
            textField.resignFirstResponder()
        }
         return true
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count >= 3
        {
            addProjectViewModel.getUsersWithName(searchText){[weak self] members in
                
                if let _ = members
                {
                self!.teamMemberViewModel = PLTeamMemberModelView(searchMembers: members!)
                searchBar.resignFirstResponder()
                self!.showPopOver()
                }
                else
                {
                    print("No matches Found")
                }
            }
        }
        else if searchText.characters.count == 0
        {
           close()
        }
    }

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return addProjectViewModel.numberOfRows()
    }
    
      func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PLTableViewCell
        cell.memberName.text = addProjectViewModel.projectTitle(indexPath.row)
        cell.memberDetail.text = addProjectViewModel.memberEmailid(indexPath.row)
        addProjectViewModel.contributorImage(indexPath.row, completion: { (avatar,error) in
            
            if let _ = avatar{
                
                cell.teamMemberProfile.image = avatar!
                cell.teamMemberProfile.layer.masksToBounds = true
            }else{
                
                cell.teamMemberProfile.image = UIImage(named:"UserImage.png")
            }
            
        })
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 55.0
    }
    
     func tableView(tableView: UITableView, commitEditingStyle editingStyle:
        UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            
            addProjectViewModel.deleteSelectedContributor(indexPath.row)
           
           self.contributorsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    
    func reloadTableViewWithContributors(member:PLTeamMember){
        
           if  addProjectViewModel.removeContributor(member)
           {
                contributorsTableView.reloadData()
           }
           else{
               close()
               showAlertWithMessage("Failed to add \(member.fullName)", message: "\(member.fullName) is already contributing to ")
          }
        
    }
    
    func cleanUp(){
        
        self.projectName.text = ""; self.projectDescription.text = ""
        self.contributorsSearchField.text = ""
        self.contributorsSearchField.prompt = "Add contributors to Project"
        addProjectViewModel.selectedContributors.removeAll()
        self.contributorsTableView.reloadData()

    }
    
    func check(details:[String],detailViewModel:PLProjectDetailViewModel)
    {
         projectDetails = details
         projectDetailViewModel = detailViewModel
        
    }
    
  
    func showPopOver() {
        
        if diplayMembersPopover == nil
        {
             diplayMembersPopover = self.storyboard?.instantiateViewControllerWithIdentifier("PLDisplayMembersPopover") as? PLDisplayMembersPopover
            setUpNavigationBarForPopover()
        }
        diplayMembersPopover.delegate = self
        diplayMembersPopover.teamMemberModelView = teamMemberViewModel;
         plPopOverController!.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        plPopOverController?.popoverContentSize = CGSizeMake(300, 200)
        plPopOverController!.wantsDefaultContentAppearance = true;
        plPopOverController?.presentPopoverFromRect(popoverbutton.bounds, inView: popoverbutton, permittedArrowDirections: WYPopoverArrowDirection.Up, animated: true)
    }
    
    func setUpNavigationBarForPopover()
    {
        diplayMembersPopover.title = "Select Contributors"
        diplayMembersPopover.modalInPopover = false
        diplayMembersPopover.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target:self, action:#selector(PLAddProjectViewController.close))
        let navigationController = UINavigationController(rootViewController: diplayMembersPopover)
         plPopOverController = WYPopoverController(contentViewController:navigationController)
    }
    
    func close(){
        
        plPopOverController?.dismissPopoverAnimated(true)
        self.contributorsSearchField.text = ""
    }
 
    @IBAction func appSharing(sender: AnyObject) {
        
        let textToShare = "Makeit is awesome! Get Ready to download the App!"
        
        if let myWebsite = NSURL(string: "http://makeitiscomingsoon/") {
            
            let image = UIImage(named:"AppIcon")
            
            let objectsToShare = [textToShare, myWebsite, image!]
          
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList,
                                                UIActivityTypePrint,
                                                UIActivityTypeAssignToContact,
                                                UIActivityTypeSaveToCameraRoll,
                                                UIActivityTypeAddToReadingList,
                                                UIActivityTypePostToFlickr,
                                                UIActivityTypePostToVimeo]
        
            if UI_USER_INTERFACE_IDIOM() == .Phone
            {
                 self.presentViewController(activityVC, animated: true, completion: nil)
            }else{
                
                let popup = UIPopoverController(contentViewController: activityVC)
                popup.presentPopoverFromRect(CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0), inView:self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
                
            }
           
        }
    }

}