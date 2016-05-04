//
//  PLChatDetailViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 04/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLChatDetailViewController: QMChatViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.senderID = (QBSession.currentSession().currentUser?.ID)!
        self.senderDisplayName = "Light"
        self.title = "Truth"
        self.view.backgroundColor = UIColor.whiteColor()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
