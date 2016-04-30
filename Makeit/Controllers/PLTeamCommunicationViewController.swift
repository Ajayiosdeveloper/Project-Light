//
//  PLTeamCommunicationViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 30/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLTeamCommunicationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var communicationType:Int!
    var communicationViewModel:PLTeamCommunicationViewModel!
    @IBOutlet var teamListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.teamListTableView.registerNib(UINib(nibName:"PLTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier: "Cell")
        teamListTableView.dataSource = self
        teamListTableView.delegate = self
       
    
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarTitle()
        clearAllSelectedCells()
        teamListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNavigationBarTitle(){
        
        switch communicationType {
        case 0:
            self.title = "Audio Conference"
        case 1:
            self.title = "Video Conference"
        default:
            print("Never")
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if communicationViewModel.numberOfRows() > 0
        {
            return communicationViewModel.numberOfRows()
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "SELECT MEMBERS FOR CONFERENCE"
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        
        return footerViewForTableView(communicationType)
        
    }
    
      func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PLTableViewCell
       
            cell.memberName.text = communicationViewModel.contributorTitleForRowAtIndexPath(indexPath.row)
            cell.memberDetail.text = "some tags"
            communicationViewModel.contributorImageRowAtIndexPath(indexPath.row, completion: { (avatar) in
                
                if let _ = avatar{
                    
                    cell.teamMemberProfile.image = avatar!
                }else{
                    
                    cell.teamMemberProfile.image = UIImage(named:"UserImage.png")
                }
                
            })
       
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
            if tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == .Checkmark
            {
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
                
                
            }
            else{
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
               
                
            }
    }


    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 55.0
    }
    
    func clearAllSelectedCells(){
        
        for cell in teamListTableView.visibleCells{
            
            cell.accessoryType = .None
        }
    }
    
    func footerViewForTableView(type:Int)->UIView{
        
        let footerView = UIView(frame: CGRectMake(0,0,self.view.frame.size.width,50))
        footerView.backgroundColor = UIColor.whiteColor()
        let imageV = UIImageView(frame:CGRectMake(10,10,40,40))
        if type == 0{
            imageV.image = UIImage(named:"audio.png")
        }else{
             imageV.image = UIImage(named:"video.png")
        }
        footerView.addSubview(imageV)
        let startConference = UIButton(type: UIButtonType.System)
        startConference.frame = CGRectMake(50, 10, 300, 40)
        startConference.addTarget(self, action:#selector(PLTeamCommunicationViewController.startConference), forControlEvents: UIControlEvents.TouchUpInside)
        startConference.setTitleColor(enableButtonColor, forState:.Normal)
        startConference.setTitle("Start Conference", forState: UIControlState.Normal)
        startConference.contentHorizontalAlignment = .Left
        startConference.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        footerView.addSubview(startConference)
        return footerView
    }
    
    func startConference(){
        
        print("PRAISE THE LORD")
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
