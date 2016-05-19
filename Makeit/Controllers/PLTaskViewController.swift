//
//  PLTaskViewController.swift
//  Makeit
//
//  Created by Tharani P on 18/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLTaskViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
   var contributors:[PLTeamMember]!
    var sidebarViewModel:PLSidebarViewModel = PLSidebarViewModel()
    var selectedType : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "PLTasksViewCell",bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Cell")
        addDoneBarButtonItem()
       }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
       if let _ = selectedType
       {
        switch selectedType {
        case 0:
           self.title = "Today Tasks"
           sidebarViewModel.getTodayTasks({ (res) in
            
            self.tableView!.reloadData()
            
           })
        case 1:
               self.title = "Upcoming Tasks"
               sidebarViewModel.getUpcomingTasks({ (res) in
               self.tableView!.reloadData()

            })
        case 2:
            self.title = "Pending Tasks"
            sidebarViewModel.getPendingTasks({ (res) in
                
                self.tableView!.reloadData()
            })
        default:
            print("")
        }
       }
    }
    
    func addDoneBarButtonItem(){
        
        let backButton = UIBarButtonItem(barButtonSystemItem:.Cancel, target: self, action: #selector(PLTaskViewController.performCancel))
        self.navigationItem.leftBarButtonItem = backButton
    }

    func performCancel()
    {
     self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sidebarViewModel.numbersOfRows()
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 105
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PLTasksViewCell
        cell.taskNameField.text = sidebarViewModel.titleOfRowAtIndexPath(indexPath.row) as String
        cell.projectNameField.text = sidebarViewModel.projectTitleOfRowAtIndexPath(indexPath.row) as String
        if selectedType == 0
        {
            cell.taskStartTime.text = "StartTime: " + sidebarViewModel.startTimeOfTask(indexPath.row)
        cell.taskEndTime.text =  "EndTime: " + sidebarViewModel.endTimeOfTask(indexPath.row)
        }
        else if selectedType == 1 || selectedType == 2
        {
         
          cell.taskStartTime.text  = "StartDate: " + sidebarViewModel.startTaskDate(indexPath.row)
          cell.taskEndTime.text = "EndDate: " + sidebarViewModel.endTaskDate(indexPath.row)
        }
       
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        let commitmentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLProjectCommentViewController") as! PLProjectCommentViewController
//        self.presentViewController(commitmentViewController, animated: true, completion: nil)
    }
    
}
