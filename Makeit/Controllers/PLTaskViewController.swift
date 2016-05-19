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
        case 3:
            print("PRAISE THE LORD")
            self.title = "Today Birthdays"
            self.tableView.registerNib(UINib.init(nibName:"PLBirthdayTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "BirthdayCell")
            sidebarViewModel.getTeamMemberBirthdayListForToday({ (res) in
                self.tableView.reloadData()
                print("The result is \(res)")
                print(self.sidebarViewModel.teamMembersForBitrhday.count)
                self.tableView.reloadData()
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
        if selectedType == 3{
        return 0
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if selectedType == 0 | 1 | 2{
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
      //  cell.textLabel!.text = sidebarViewModel.titleOfRowAtIndexPath(indexPath.row) as String
      //  cell.detailTextLabel!.text = sidebarViewModel.detailTitleOfRowAtIndexPath(indexPath.row) as String
        return cell
        }else{
           
        let cell = tableView.dequeueReusableCellWithIdentifier("BirthdayCell") as! PLBirthdayTableViewCell
           // cell.memberName.text = "Immanual"
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if selectedType == 3{
            return 130
        }
        return 44
    }
}
