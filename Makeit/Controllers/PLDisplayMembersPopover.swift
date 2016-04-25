//
//  PLDisplayMembersPopover.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 20/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

protocol PLContributorTableViewDelegate:class {
    
    func reloadTableViewWithComtributors(member:PLTeamMember)
    
}

class PLDisplayMembersPopover: UITableViewController {
    
    var teamMemberModelView:PLTeamMemberModelView!
    
    var selectedRows = NSMutableArray()
   
    weak var delegate:PLContributorTableViewDelegate?
    
    @IBOutlet var membersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.presentingViewController != nil && teamMemberModelView != nil && teamMemberModelView.numbersOfRows() > 0){
            
            self.preferredContentSize = membersTableView.sizeThatFits((self.presentingViewController?.view.bounds.size)!)
            membersTableView.reloadData()
        }
    }
    
    //MARK: UITableView DataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return teamMemberModelView.numbersOfRows()
        
    }
    
    override  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        cell.textLabel?.text = teamMemberModelView.titleOfRowAtIndexPath(indexPath.row)
        return cell
    }

  override  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
            if teamMemberModelView.isContributorAlreadyAdded(indexPath.row)
            {
                let name = teamMemberModelView.titleOfRowAtIndexPath(indexPath.row)
                 showAlertWithMessage("Failed to add \(name)", message: "\(name) is already contributing to \("Project")")
            }
            else{
                
                if tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == .Checkmark
                {
                    tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
                    
                    let contributor =  teamMemberModelView.remove(indexPath.row)
                    
                    if let _ = delegate{ delegate?.reloadTableViewWithComtributors(contributor) }
                    
                }
                else{
                    tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
                    
                    let contributor  = teamMemberModelView.add(indexPath.row)
                    
                    if let _ = delegate{ delegate?.reloadTableViewWithComtributors(contributor) }
                    
                }
            }
    
   
   }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == teamMemberModelView.numbersOfRows() - 1
        {
            if indexPath.row >= 25{ print("Fetch New Members here") }
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
   
    
}
