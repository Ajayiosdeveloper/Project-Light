//
//  PLProjectDetailTableViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

protocol ProjectDetailsDelegate:class{
    func check(details:[String],detailViewModel:PLProjectDetailViewModel)
}

class PLProjectDetailTableViewController: UITableViewController {
    weak var delegate:ProjectDetailsDelegate?
    var projectDetailViewModel:PLProjectDetailViewModel!
    var projectName:String!
    var projectId:String!
    var projectDescription:String!
    var addProjectViewController:PLAddProjectViewController!
    var commitmentViewController:PLProjectCommentViewController!
    var assignmentViewController:PLProjectAssignmentViewController!

    @IBOutlet var projectDetailsTableView: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchDataFromRemote()
        self.navigationItem.title = projectName
        projectDetailsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
  
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var total = 0
        if section == 0 {
           total = projectDetailViewModel.numbersOfContributorsRows()
        }
        else if section == 1{
            total = projectDetailViewModel.numberOfCommitmentRows()
        }
        else if section == 2
        {
            total = projectDetailViewModel.numberOfAssignmentRows()
        }
        else if section == 3
        {
            total = 3
        }
        return total
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if indexPath.section == 0{
        cell.textLabel?.text = projectDetailViewModel.contributorTitleForRowAtIndexPath(indexPath.row)
        cell.textLabel?.textColor = UIColor.blackColor()
        }
        else if indexPath.section == 1{
            
            cell.textLabel?.text = projectDetailViewModel.commitmentTitleForRowAtIndexPath(indexPath.row)
            cell.detailTextLabel?.text = projectDetailViewModel.commitmentSubTitleForRowAtIndexPath(indexPath.row)
            cell.textLabel?.textColor = UIColor.blackColor()
        }
        else if indexPath.section == 2{
            
            cell.textLabel?.text = projectDetailViewModel.assignmentTitleForRowAtIndexPath(indexPath.row)
            cell.detailTextLabel?.text = projectDetailViewModel.assignmentSubTitleForRowAtIndexPath(indexPath.row)
            cell.textLabel?.textColor = UIColor.blackColor()
        }
        else if indexPath.section == 3{
            
            cell.textLabel?.text = projectDetailViewModel.communicationType(indexPath.row)
            cell.detailTextLabel?.text = ""
            cell.textLabel?.textColor = enableButtonColor
        }
       
        return cell
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        
//    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var footerView:UIView! = UIView(frame:CGRectMake(0,0,self.view.frame.size.width,40))
        footerView.backgroundColor = UIColor.whiteColor()
        if section == 0
        {
            self.addButtonForTableViewFooterOnView(footerView, title:"Add Contributor", tag:section)
        }
        else if section == 1{
            
            self.addButtonForTableViewFooterOnView(footerView, title:"Add Commitment", tag:section)

        }
        else if section == 2{
            
            self.addButtonForTableViewFooterOnView(footerView, title:"Add Assigniment", tag:section)
        }
        else if section == 3
        {
            footerView = nil
        }
        
       return footerView
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var headerTitle:String = ""
        if section == 0{
            headerTitle = "CONTRIBUTORS"
        }
        else if section == 1
        {
            headerTitle = "COMMITMENTS"
        }
        else if section == 2
        {
            headerTitle = "ASSIGNMENTS"
        }
        else if section == 3
        {
            headerTitle = "COMMUNICATE"
        }
        
        return headerTitle
        
    }
    
    override   func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func addButtonForTableViewFooterOnView(addOnView:UIView,title:String,tag:Int)
    {
        let addMemberButton = UIButton(type:.Custom)
        addMemberButton.tag = tag
        addMemberButton.setTitle(title, forState: UIControlState.Normal)
        addMemberButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        addMemberButton.setTitleColor(enableButtonColor, forState: UIControlState.Normal)
        addMemberButton.addTarget(self, action:#selector(PLProjectDetailTableViewController.addNewContributor), forControlEvents: UIControlEvents.TouchUpInside)
        addMemberButton.frame = CGRectMake(-10, 0, self.view.frame.size.width/2, 40)
        addOnView.addSubview(addMemberButton)
    }
    
    func addNewContributor(sender:UIButton) {
        
        if sender.tag == 0{
            
           if addProjectViewController == nil
           {
             addProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLAddProjectViewController") as! PLAddProjectViewController
            }
           PLSharedManager.manager.existingContributorsList = projectDetailViewModel.contributors
           self.delegate = addProjectViewController
           self.navigationController?.pushViewController(addProjectViewController, animated:true)
           self.delegate?.check([projectId,projectName,projectDescription],detailViewModel: self.projectDetailViewModel)
 
        }
        if sender.tag == 1
        {
            showCommitmentViewController()
        }
        else if sender.tag == 2
        {
            showAssignmentViewController()
        }
    }
    
    func  showCommitmentViewController() {
        
        if commitmentViewController == nil{
        
            commitmentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLProjectCommentViewController") as! PLProjectCommentViewController
            }
        commitmentViewController.projectId = projectId
       
    
        self.navigationController?.pushViewController(commitmentViewController, animated: true)
    }
 
    func  showAssignmentViewController() {
        
        if assignmentViewController == nil{
            
            assignmentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLProjectAssignmentViewController") as! PLProjectAssignmentViewController
        }
        assignmentViewController.projectId = projectId
        assignmentViewController.assignementViewModel = PLProjectAssignmentViewModel(assignees: projectDetailViewModel.getProjectContributorsList())
        self.navigationController?.pushViewController(assignmentViewController, animated: true)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0
        {
            let x = projectDetailViewModel.contributors[indexPath.row]
            print(x.fullName)
            print(x.memberId)
            print(x.memberUserId)
        
        }
        else if indexPath.section  == 1
        {
            showCommitmentViewController()
             commitmentViewController.commitmentViewModel.commitment = projectDetailViewModel.selectedCommitmentFor(indexPath.row)
            print(commitmentViewController.commitmentViewModel.commitment)
            
        }
        else if indexPath.section == 2
        {
            showAssignmentViewController()
            assignmentViewController.assignementViewModel.selectedAssignment = projectDetailViewModel.selectedAssignment(indexPath.row)
        }
        
        else if indexPath.section == 3{
            
            if indexPath.row == 0 {print("Show Voice Chat members list")}
            else if indexPath.row == 1 {print("Show Video Chat members list")}
            else {print("Show Text Chat of Team")}
            
        }
        
    }
    
    func fetchDataFromRemote()  {
        
        projectDetailViewModel.assignments = []
        projectDetailViewModel.commitments = []
        projectDetailViewModel.getCommitmentsFromRemote(projectId){[weak self]result in
            
            if result{  self!.projectDetailViewModel.getAssignmentsFromRemote(self!.projectId){result in
                
                if result{
                    self?.projectDetailsTableView.reloadData()
                }
                }
            }
        }
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
