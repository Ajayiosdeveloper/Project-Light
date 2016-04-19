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
    var projectViewModel:PLProjectsViewModel!
    var activityIndicatorView:UIActivityIndicatorView!
    var animateCell:[Bool] = [Bool]()
    var observerContext = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Projects"
        addLogoutBarButtonItem()
        addNewProject()
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        projectViewModel = PLProjectsViewModel()
        projectViewModel.addObserver(self, forKeyPath:"projectList", options: NSKeyValueObservingOptions.New, context:&observerContext)
            projectViewModel.fetchProjectsFromRemote()
        addActivityIndicatorView()
    }
    
    func  addActivityIndicatorView() {
        if activityIndicatorView == nil{
            
          activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.hidesWhenStopped = true
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
        }
    }
    
    func addLogoutBarButtonItem(){
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target:self, action:#selector(PLProjectsViewController.performLogout))
         }
    
    func performLogout()
    {
        if observerContext == 0 {projectViewModel.removeObserver(self, forKeyPath:"projectList")}
        projectViewModel.performLogout()
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
        if observerContext == 0 {projectViewModel.removeObserver(self, forKeyPath:"projectList")}
    }
    
   //MARK: UITableView DataSource
    
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return projectViewModel.rowsCount()
    
    }
    
   override  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
            cell.textLabel?.text = projectViewModel.titleAtIndexPath(indexPath.row)
            cell.detailTextLabel?.text = projectViewModel.subTitleAtIndexPath(indexPath.row)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selected = projectViewModel.didSelectRowAtIndex(indexPath.row) as PLProject
        print(selected.name)
        print(selected.subTitle)
        print(selected.createdBy)
        print(selected.projectId)
        print(selected.parentId)
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle:
        UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            activityIndicatorView.startAnimating()
            projectViewModel.deleteProjectAtIndexPathOfRow(indexPath.row){[weak self] result in
                
                if result{
                    self!.activityIndicatorView.stopAnimating()
                    self!.projectViewModel.projectList.removeAtIndex(indexPath.row)
                    self!.projectTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
                }
            
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
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
        {    if projectViewModel.rowsCount() > 0
          {
            for _ in 0...projectViewModel.rowsCount(){ animateCell.append(false)}
            activityIndicatorView.stopAnimating()
            projectTableView.reloadData()
            projectViewModel.removeObserver(self, forKeyPath:"projectList")
            observerContext = 1
            }
        }
        
    }
}
