//
//  PLTeamCommunicationViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 30/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLTeamCommunicationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,QBRTCClientDelegate,UIAlertViewDelegate
{
    var communicationType:Int!
    var currentSession:QBRTCSession!
    var communicationViewModel:PLTeamCommunicationViewModel!
    var teamChatViewController:PLProjectTeamChatViewController!
    var textFld = UITextField()
    
    @IBOutlet var teamListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.teamListTableView.registerNib(UINib(nibName:"PLTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier: "Cell")
        teamListTableView.dataSource = self
        teamListTableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if communicationType == 2{
            
            self.navigationItem.rightBarButtonItem = addCreateGroupBarButton()
        }
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
        case 1:
            self.title = "Create Group"
            
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
        
        if communicationType == 2{
            return "SELECT MEMBERS FOR GROUP"
        }
        
        return "SELECT MEMBERS FOR CONFERENCE"
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if communicationType == 2{
            return nil
        }
        
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
            communicationViewModel.removeTeamMemberAtRow(indexPath.row)
            
        }
        else{
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            communicationViewModel.addTeamMemberAtRow(indexPath.row)
            
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
    
    func addCreateGroupBarButton()->UIBarButtonItem{
        
        let createGroup = UIBarButtonItem(title:"Create", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PLTeamCommunicationViewController.createNewChatGroupForProject))
        self.navigationItem.rightBarButtonItem = createGroup
        return createGroup
    }
    
    func createNewChatGroupForProject()  {
        
        print("Create Chat Group Here")
        
        if #available(iOS 8.0, *) {
            let alertViewController = UIAlertController.init(title: "Enter Group Name", message: nil, preferredStyle: .Alert)
            let okAction = UIAlertAction.init(title: "Ok", style: .Default) {[weak self] (action) -> Void in
                
                self!.communicationViewModel.createProjectGroup(self!.textFld.text!){[weak self] resu, chatGroup in
                    if resu{
                        self!.teamChatViewController.projectTeamChatViewModel.addChatGroup(chatGroup!)
                        self?.navigationController?.popViewControllerAnimated(true)
                    }
                    else{
                        print("Failed")
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
            alertViewController.addAction(okAction)
            alertViewController.addAction(cancelAction)
            alertViewController.addTextFieldWithConfigurationHandler {[weak self] (textField) -> Void in
                // self?.textFld.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 30.0)
                self?.textFld = textField
            }
              self.presentViewController(alertViewController, animated: true, completion: nil)
        } else {
            let alertView = UIAlertView(title: "Enter Group Name", message: "", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Ok", "Cancel")
            alertView.alertViewStyle = .PlainTextInput
            alertView.show()
            // Fallback on earlier versions
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 0{
        
            let text = alertView.textFieldAtIndex(0)! as UITextField
                self.communicationViewModel.createProjectGroup(text.text!){[weak self] resu, chatGroup in
                    if resu{
                        self!.teamChatViewController.projectTeamChatViewModel.addChatGroup(chatGroup!)
                        self?.navigationController?.popViewControllerAnimated(true)
                    }
                    else{
                        print("Failed")
                    }
            }
        }
        else{
            print("Cancel clicked")
        }
    }



    func startConference(){
        
        print("PRAISE THE LORD")
        
        if communicationType == 0{
            
           // self.callWithConferenceType(.Audio)
        }
        else if communicationType == 1{
            
            //self.callWithConferenceType(.Video)
        }
        
    }
    
   /* func callWithConferenceType(type:QBRTCConferenceType){
        
        if  communicationViewModel.isAnymemberSelected(){
            
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().addDelegate(self)
        let opponentsIds =  communicationViewModel.selectedMembersUserIdsForConference()
        let session = QBRTCClient.instance().createNewSessionWithOpponents(opponentsIds, withConferenceType: type)
            if (session != nil){
               currentSession = session
               currentSession.startCall(nil)
            }
            else{
                
                print("Session Not Created Please login first")
                
            }
            
        }else{
            
            print("No Member Selected for Conference")
        }
        
    }
    
    
    func didReceiveNewSession(session: QBRTCSession!, userInfo: [NSObject : AnyObject]!) {
        
        if self.currentSession != nil{
            
           var info = Dictionary<String,String>()
           info["Key"] = "Busy"
           session.rejectCall(info)
           return
        }
        self.currentSession = session
    }
    
    func session(session: QBRTCSession!, acceptedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        
        print("Accepted by User \(userID)")
        self.currentSession.acceptCall(userInfo)
    }
    
    func session(session: QBRTCSession!, rejectedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        
        print("Rejected By User \(userID)")
        self.currentSession.rejectCall(userInfo)
    }*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    deinit{
        QBRTCClient.deinitializeRTC()
    }

}
