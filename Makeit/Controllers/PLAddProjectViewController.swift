//
//  PLAddProjectViewController.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 18/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLAddProjectViewController: UIViewController,UISearchBarDelegate,UITextFieldDelegate {
    
    @IBOutlet var projectName: UITextField!
    @IBOutlet var projectDescription: UITextField!
    
    @IBOutlet var contributorsSearchField: UISearchBar!
    
    lazy var addProjectViewModel:PLAddProjectViewModel = {
     
        return PLAddProjectViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneBarButtonItem()
        projectName.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.projectName.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addDoneBarButtonItem(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target:self, action:#selector(PLAddProjectViewController.performDone))
    }
   
    func performDone()
    {
        addProjectViewModel.addObserver(self, forKeyPath:"isProjectCreated", options: NSKeyValueObservingOptions.New, context:nil)
        if addProjectViewModel.validateProjectDetails(projectName.text!){
            addProjectViewModel.createNewProjectWith(projectName.text!,description:projectDescription.text!)
        }else {showAlertWithMessage("error!", message:"enter Project name")}
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "isProjectCreated" {
        if let _ = change, value = change![NSKeyValueChangeNewKey]{
            
            if value as! NSNumber == 1 {
            
              self.navigationController?.popViewControllerAnimated(true)
              self.projectName.text = ""; self.projectDescription.text = ""
            }
            else{ // Handling Alert Messages for Login
                
            }
        }
          addProjectViewModel.removeObserver(self, forKeyPath:"isProjectCreated")
      }
    
    }
    
    func showAlertWithMessage(title:String,message:String)
    {
        if #available(iOS 9, *)
        {
            let alertController = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            alertController.addAction(action)
            self.presentViewController(alertController, animated:true, completion:nil)
        }
        else{
            let alert = UIAlertView(title: title, message: message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok") as UIAlertView
            alert.show()
        }
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        contributorsSearchField.prompt = "Add contributors to \(newString)"
        
        
        
        return true
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 3
        {
           // addProjectViewModel.getUsersWithName(searchText)
        }
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
