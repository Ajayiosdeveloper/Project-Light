//
//  PLProjectsViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 16/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit


class PLProjectsViewController: UITableViewController {
    
    @IBOutlet var projectTableView: UITableView!
    
    var addProjectViewController:PLAddProjectViewController?
    var addProjectViewModel:PLProjectsViewModel!
    var animateCell:[Bool] = [Bool]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Projects"
        addLogoutBarButtonItem()
        addNewProject()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addProjectViewModel = PLProjectsViewModel()
        addProjectViewModel.addObserver(self, forKeyPath:"projectList", options: NSKeyValueObservingOptions.New, context:nil)
            addProjectViewModel.fetchProjectsFromRemote()
    }
    
    func addLogoutBarButtonItem(){
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target:self, action:#selector(PLProjectsViewController.performLogout))
         }
    
    func performLogout()
    {
        addProjectViewModel.performLogout()
        self.projectTableView.reloadData()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func addNewProject()
    {
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(PLProjectsViewController.addNewProjectToList))
    }
    
    func addNewProjectToList()
    {
        if addProjectViewController == nil{
           addProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PLAddProjectViewController") as? PLAddProjectViewController
        }
        self.navigationController?.pushViewController(addProjectViewController!, animated: true)
    }
    
   //MARK: UITableView DataSource
    
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return addProjectViewModel.rowsCount()
    
    }
    
   override  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
            cell.textLabel?.text = addProjectViewModel.titleAtIndexPath(indexPath.row)
            cell.detailTextLabel?.text = addProjectViewModel.subTitleAtIndexPath(indexPath.row)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selected = addProjectViewModel.didSelectRowAtIndex(indexPath.row) as PLProject
        print(selected.name)
        print(selected.subTitle)
        print(selected.createdBy)
        print(selected.projectId)
        print(selected.parentId)
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if !animateCell[indexPath.row]
        {
            let transformRotate = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
            cell.layer.transform = transformRotate
            UIView.animateWithDuration(0.5) {
                
                cell.layer.transform = CATransform3DIdentity
            }
        }
        animateCell[indexPath.row] = true
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "projectList"
        {    if addProjectViewModel.rowsCount() > 0
          {
            for _ in 0...addProjectViewModel.rowsCount(){ animateCell.append(false)}
            projectTableView.reloadData()
            addProjectViewModel.removeObserver(self, forKeyPath:"projectList")
            
            }
        }
        
    }
}
