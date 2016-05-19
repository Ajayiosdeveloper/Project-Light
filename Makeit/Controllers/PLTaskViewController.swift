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
    
        addDoneBarButtonItem()
       }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Task View"
       if let _ = selectedType
       {
        switch selectedType {
        case 0:
           sidebarViewModel.getTodayTasks({ (res) in
            
            self.tableView!.reloadData()
            
           })
        case 1:
               sidebarViewModel.getUpcomingTasks({ (res) in
               self.tableView!.reloadData()

            })
        case 2:
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        cell.textLabel!.text = sidebarViewModel.titleOfRowAtIndexPath(indexPath.row) as String
        cell.detailTextLabel!.text = sidebarViewModel.detailTitleOfRowAtIndexPath(indexPath.row) as String
        return cell
    }
}
