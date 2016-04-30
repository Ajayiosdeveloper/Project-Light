//
//  PLTeamMemberDetailsTableViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 23/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLTeamMemberDetailsTableViewController: UITableViewController {
    
    var teamMemberDetailViewModel:PLTeamMemberDetailViewModel!

    @IBOutlet var memberDetailsTableview: UITableView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
      super.viewWillAppear(animated)
      self.title = teamMemberDetailViewModel.getTeamMemberName()
        teamMemberDetailViewModel.getAssignmentsOfUserForProject(){[weak self] res in
            
            if res{self!.memberDetailsTableview.reloadData()}
        }
        
      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return teamMemberDetailViewModel.getNumberOfAssignmentRows()
        }
        else if section == 1{
            return teamMemberDetailViewModel.getNumberOfCommunicateRows()
        }
        
        return 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if indexPath.section == 0{
        cell.textLabel?.text = teamMemberDetailViewModel.getAssignmentTitle(indexPath.row)
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.detailTextLabel?.hidden = false
        cell.detailTextLabel?.text = teamMemberDetailViewModel.getAssignmentDetail(indexPath.row)
        }else if indexPath.section == 1{
          cell.textLabel?.text = teamMemberDetailViewModel.getCommunicateTitle(indexPath.row)
          cell.detailTextLabel?.hidden = true
          cell.textLabel?.textColor = enableButtonColor
        }
        return cell
    }
    
   override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
     if section == 0{
        return "Assignments"
      }
     else if section == 1{
        return "Communicate"
    }
        return ""
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
