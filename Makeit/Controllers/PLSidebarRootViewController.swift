//
//  PLSidebarRootViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 10/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLSidebarRootViewController: DLHamburguerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        self.contentViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("DLDemoNavigationViewController"))! as UIViewController
        self.menuViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("DLDemoMenuViewController"))! as UIViewController
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
