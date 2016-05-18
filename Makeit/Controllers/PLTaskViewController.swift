//
//  PLTaskViewController.swift
//  Makeit
//
//  Created by Tharani P on 18/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLTaskViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   var contributors:[PLTeamMember]!
    var commitmentsName = NSMutableArray()
    var commitmentsDescription = NSMutableArray()
    var projectViewModel:PLProjectsViewModel = PLProjectsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("commitmentViewModel.commitments")
    //   print(projectDetailViewModel.numberOfCommitmentRows())
          print("commitmentViewModel.commitments")
        commitmentsName.addObject("hai")
        commitmentsDescription.addObject("hello")
       }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commitmentsName.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = commitmentsName[indexPath.row] as? String
        cell.detailTextLabel?.text = commitmentsDescription[indexPath.row] as? String
        return cell
    }
}
