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
    var birthdayRange : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "PLTasksViewCell",bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Cell")
        self.tableView.registerNib(UINib(nibName:"PLBirthdayTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "BirthdayCell")
        addBackBarButtonItem()
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
        case 3:
            print("PRAISE THE LORD")
          
            if birthdayRange == 0
            {
                  self.title = "Today Birthdays"
                sidebarViewModel.getTeamMemberBirthdayListForToday(0
                    , completion: { (res) in
                        self.tableView.reloadData()
                })
        
            }
            else{
                self.title = "Upcoming Birthdays"
                sidebarViewModel.getTeamMemberBirthdayListForToday(1
                    , completion: { (res) in
                        self.tableView.reloadData()
                })
            }
            
        default:
            print("")
        }
       }
    }
    
    func addBackBarButtonItem(){
        
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
        if selectedType == 3{
        return sidebarViewModel.numberOfBirthdayRows()
        }
        return sidebarViewModel.numbersOfRows()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if selectedType != 3 {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PLTasksViewCell
            
            cell.taskNameField.text = "Task:  " + sidebarViewModel.titleOfRowAtIndexPath(indexPath.row)
            cell.projectNameField.text =  "Project: " + sidebarViewModel.projectTitleOfRowAtIndexPath(indexPath.row)
            cell.detailsField.text = "Detail: " + sidebarViewModel.commitmentDetails(indexPath.row)
            if selectedType == 0
            {
                cell.taskStartTime.text = "StartTime: " + sidebarViewModel.startTimeOfTask(indexPath.row)
                cell.taskEndTime.text =  "EndTime: " + sidebarViewModel.endTimeOfTask(indexPath.row)
            }
            else if selectedType == 1 || selectedType == 2
            {
                
                cell.taskStartTime.text  = "Start: " + sidebarViewModel.startTaskDate(indexPath.row)
                cell.taskEndTime.text = "End: " + sidebarViewModel.endTaskDate(indexPath.row)
            }
            cell.accessoryType = .DisclosureIndicator
            return cell
        }
        else{
           
        let cell = self.tableView.dequeueReusableCellWithIdentifier("BirthdayCell") as! PLBirthdayTableViewCell
            cell.memberName.text = sidebarViewModel.birthdayMemberName(indexPath.row)
            cell.memberDetail.text = sidebarViewModel.birthdayMemberEmail(indexPath.row)
            cell.memberImage.layer.masksToBounds = true
            if birthdayRange == 0
            {
                cell.birthdayDate.text = ""
            }
            else
            {
                cell.birthdayDate.text = sidebarViewModel.teamMembersBirthday(indexPath.row)
            }
            sidebarViewModel.contributorImageRowAtIndexPath(indexPath.row, completion: { (avatar) in
                
                if let _ = avatar{
                    
                    cell.memberImage.image = avatar!
                    cell.memberImage.layer.masksToBounds = true
                }else{
                    
                    cell.memberImage.image = UIImage(named:"UserImage.png")
                }
            })
            
            cell.makeCall.addTarget(self, action: #selector(PLTaskViewController.makeCall), forControlEvents: UIControlEvents.TouchUpInside)
            cell.makeCall.tag = indexPath.row
            cell.makeMessage.addTarget(self, action: #selector(PLTaskViewController.sendMessage), forControlEvents: UIControlEvents.TouchUpInside)
            cell.makeMessage.tag = indexPath.row
            cell.sendBirthdayGreetings.addTarget(self, action: #selector(PLTaskViewController.sendBirthdayGreetings), forControlEvents: UIControlEvents.TouchUpInside)
            cell.sendBirthdayGreetings.tag = indexPath.row
            //cell.accessoryType = .DisclosureIndicator
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) ->
        CGFloat
    {
        if selectedType == 3
        {
            return 100
        }
        return 105
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let transform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
        cell.layer.transform = transform
        UIView.animateWithDuration(0.2) {
            
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
    func makeCall(sender:UIButton){
        let callUrl = NSURL(string:"telprompt://")
        if UIApplication.sharedApplication().canOpenURL(callUrl!){
            
            UIApplication.sharedApplication().openURL(callUrl!)
        }else{
            print("Can not make a call")
        }
    }
    
    func sendMessage(sender:UIButton){
        
        let message = NSURL(string:"sms://")
        if UIApplication.sharedApplication().canOpenURL(message!){
            
            UIApplication.sharedApplication().openURL(message!)
        }else{
            print("Can not make sms")
        }
    }
    
    func sendBirthdayGreetings(sender:UIButton){
        
        print(sender.tag)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.sidebarViewModel.commitments = []
        self.sidebarViewModel.teamMembersForBitrhday = []
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if selectedType != 3
        {
        let commitmentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLProjectCommentViewController") as! PLProjectCommentViewController
        commitmentViewController.commitmentViewModel = PLProjectCommentViewModel()
        commitmentViewController.commitmentViewModel.commitment = sidebarViewModel.getSelectedCommitment(indexPath.row)
        commitmentViewController.projectId = sidebarViewModel.projectIdForSelectedCommitement(indexPath.row)
        let navigation = UINavigationController(rootViewController: commitmentViewController)
        self.presentViewController(navigation, animated: true, completion: nil)
        commitmentViewController.addBackBarButtonItem()
        }
    }
    
}
