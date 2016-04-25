//
//  PLAddProjectViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 18/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit


class PLAddProjectViewController: UIViewController,UISearchBarDelegate,UITextFieldDelegate,UIPopoverPresentationControllerDelegate,UITableViewDelegate,UITableViewDataSource,PLContributorTableViewDelegate,ProjectDetailsDelegate {
    
    @IBOutlet var projectName: UITextField!
    @IBOutlet var projectDescription: UITextField!
    @IBOutlet var contributorsSearchField: UISearchBar!
    var  diplayMembersPopover:PLDisplayMembersPopover!
    var activityIndicatorView:UIActivityIndicatorView!
    var teamMemberViewModel:PLTeamMemberModelView!
    var projectDetails:[String]!
    var projectDetailViewModel:PLProjectDetailViewModel!
   
    
    @IBOutlet var contributorsTableView: UITableView!
    
    lazy var addProjectViewModel:PLAddProjectViewModel = {
     
        return PLAddProjectViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneBarButtonItem()
        projectName.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.projectName.becomeFirstResponder()
        addActivityIndicatorView()
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
   
    func performDone()
    {
        activityIndicatorView.startAnimating()
        addProjectViewModel.addObserver(self, forKeyPath:"isProjectCreated", options: NSKeyValueObservingOptions.New, context:nil)
        if projectDetails == nil{
        if addProjectViewModel.validateProjectDetails(projectName.text!){
            addProjectViewModel.createNewProjectWith(projectName.text!,description:projectDescription.text!)
        }else {activityIndicatorView.stopAnimating();showAlertWithMessage("error!", message:"enter Project name")}
        }
        else{
            
            addProjectViewModel.addContributorsToExistingProject(projectDetails![0]){[weak self] members in
                
                self!.projectDetailViewModel.contributors.appendContentsOf(members)
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "isProjectCreated" {
        if let _ = change, value = change![NSKeyValueChangeNewKey]{
            
            activityIndicatorView.stopAnimating()
            if value as! NSNumber == 1 {
            
              self.navigationController?.popViewControllerAnimated(true)
              
             self.cleanUp()
            
            }
            else{ // Handling Alert Messages for Login
                
            }
        }
          addProjectViewModel.removeObserver(self, forKeyPath:"isProjectCreated")
      }
    
    }
    
    func showAlertWithMessage(title:String,message:String)
    {
        if #available(iOS 9, *)
        {
            let alertController = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            alertController.addAction(action)
            self.presentViewController(alertController, animated:true, completion:nil)
        }
        else{
            let alert = UIAlertView(title: title, message: message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok") as UIAlertView
            alert.show()
        }
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        contributorsSearchField.prompt = "Add contributors to \(newString)"
        
        
        
        return true
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count >= 3
        {
            addProjectViewModel.getUsersWithName(searchText){[weak self] members in
                
                if let _ = members{
                self!.teamMemberViewModel = PLTeamMemberModelView(searchMembers: members!)
                self!.performSegueWithIdentifier("DisplayMembersPopover", sender:self)
                }else{print("No matches Found")}
                
            }
        }
        if searchText.characters.count == 0
        {
            dismissPopover()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        diplayMembersPopover = segue.destinationViewController as? PLDisplayMembersPopover
        
        diplayMembersPopover.delegate = self
        
        if #available(iOS 8.0, *) {
            
             diplayMembersPopover.teamMemberModelView = teamMemberViewModel;
             diplayMembersPopover.popoverPresentationController?.delegate = self
             diplayMembersPopover.popoverPresentationController?.permittedArrowDirections = .Down
            } else {
            // Fallback on earlier versions
        }
    }
    
    
    @available(iOS 8.0, *)
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .None
    }
    
    func dismissPopover()  {
       
        if let _ = diplayMembersPopover{
            
            diplayMembersPopover.dismissViewControllerAnimated(true, completion:nil)
        }
    }

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return addProjectViewModel.numberOfRowsInTableView()
    }
    
      func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        cell.textLabel?.text = addProjectViewModel.titleAtIndexPathOfRow(indexPath.row)
        
        return cell
    }
    
     func tableView(tableView: UITableView, commitEditingStyle editingStyle:
        UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            
            addProjectViewModel.deleteSelectedContributor(indexPath.row)
           
           self.contributorsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
           
        }
    }
    
    
    func reloadTableViewWithComtributors(member:PLTeamMember){
        
           if  addProjectViewModel.andOrRemoveContributor(member)
           {
                dismissPopover()
                contributorsTableView.reloadData()
           }
           else{
            
               dismissPopover()
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
    
  

}
