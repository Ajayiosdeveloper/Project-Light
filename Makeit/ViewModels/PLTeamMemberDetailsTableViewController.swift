//
//  PLTeamMemberDetailsTableViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 23/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLTeamMemberDetailsTableViewController: UITableViewController {
    
    var teamMemberDetailViewModel:PLTeamMemberDetailViewModel!
    
    @IBOutlet var memberDetailsTableview: UITableView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.memberDetailsTableview.registerNib(UINib(nibName: "PLTeamMemberDetailsTableViewCell",bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Cells")
        self.memberDetailsTableview.registerClass(UITableViewCell.self, forCellReuseIdentifier:"DefaultCell")
    }

    override func viewWillAppear(animated: Bool) {
      super.viewWillAppear(animated)
      self.title = teamMemberDetailViewModel.getTeamMemberName()
        teamMemberDetailViewModel.getAssignmentsOfUserForProject(){[weak self] res,err in
            
            if res{
                self!.memberDetailsTableview.reloadData()
            }
            else
            {
                PLSharedManager.showAlertIn(self!, error: err!, title: "Error occured while fetching user from the server", message: err.debugDescription)
            }
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

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        PLDynamicEngine.animateCell(cell, withTransform: PLDynamicEngine.TransformCurl, andDuration:1)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cells", forIndexPath: indexPath) as! PLTeamMemberDetailsTableViewCell
        cell.assignmentTitle.text = teamMemberDetailViewModel.getAssignmentTitle(indexPath.row)
        cell.assignmentDetail.hidden = false
        cell.statusField.hidden = false
        cell.startTime.hidden = false
        cell.endTime.hidden = false
        cell.startTime.text = "Start: " + teamMemberDetailViewModel.getAssignmentStartDateWithTime(indexPath.row)
        cell.endTime.text =
            "End: " + teamMemberDetailViewModel.getAssignmentTargetDateWithTime(indexPath.row)
        cell.assignmentDetail.text = teamMemberDetailViewModel.getAssignmentDetail(indexPath.row)
        return cell
        }
        else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)  as UITableViewCell
            cell.textLabel?.text = teamMemberDetailViewModel.getCommunicateTitle(indexPath.row)
            cell.detailTextLabel?.text = ""
            cell.textLabel?.textColor = enableButtonColor
            return cell
        }
        return UITableViewCell()
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0
        {
        return 76
        }
        else if indexPath.section == 1
        {
        return 44
        }
        return 0
    }
}
