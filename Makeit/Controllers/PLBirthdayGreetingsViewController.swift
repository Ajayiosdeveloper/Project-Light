//
//  PLBirthdayGreetingsViewController.swift
//  Makeit
//
//  Created by Tharani P on 01/06/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit
import Quickblox

class PLBirthdayGreetingsViewController: UIViewController,UIScrollViewDelegate,UIAlertViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var sendGreetingCard: UIButton!
    @IBOutlet var pageControl: UIPageControl!
    var timer : NSTimer!
    var selectedImage : Int = 0
    var birthdayField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        let scrollViewWidth:CGFloat = self.scrollView.frame.width
        let scrollViewHeight:CGFloat = self.scrollView.frame.height
        self.sendGreetingCard.layer.cornerRadius = 4.0
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.pagingEnabled = true
        let imgOne = UIImageView(frame: CGRectMake(0, 0,scrollViewWidth, scrollViewHeight))
        imgOne.image = UIImage(named: "birthday_1")
        let imgTwo = UIImageView(frame: CGRectMake(scrollViewWidth, 0,scrollViewWidth, scrollViewHeight))
        imgTwo.image = UIImage(named: "birthday_2")
        let imgThree = UIImageView(frame: CGRectMake(scrollViewWidth*2, 0,scrollViewWidth, scrollViewHeight))
        imgThree.image = UIImage(named: "birthday_3")
        let imgFour = UIImageView(frame: CGRectMake(scrollViewWidth*3, 0,scrollViewWidth, scrollViewHeight))
        imgFour.image = UIImage(named: "birthday_4")
        
        self.scrollView.addSubview(imgOne)
        self.scrollView.addSubview(imgTwo)
        self.scrollView.addSubview(imgThree)
        self.scrollView.addSubview(imgFour)
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width * 4, self.scrollView.frame.height)
        self.scrollView.delegate = self
        self.pageControl.currentPage = 0
        
       //timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(PLBirthdayGreetingsViewController.moveToNextPage), userInfo: nil, repeats: true)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveToNextPage (){
        
        let pageWidth:CGFloat = CGRectGetWidth(self.scrollView.frame)
        let maxWidth:CGFloat = pageWidth * 4
        let contentOffset:CGFloat = self.scrollView.contentOffset.x
        
        var slideToX = contentOffset + pageWidth
        
        if  contentOffset + pageWidth == maxWidth{
            slideToX = 0
        }
        self.scrollView.scrollRectToVisible(CGRectMake(slideToX, 0, pageWidth, CGRectGetHeight(self.scrollView.frame)), animated: true)
    }
    
    @IBAction func sendGreetingsAction(sender: AnyObject) {
        
      //  timer.invalidate()
        if #available(iOS 8.0, *) {
            let alertController: UIAlertController = UIAlertController(title: "Enter Text", message:"", preferredStyle: .Alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
                
                print("Selected Image in ok action \(self.selectedImage)")
            PLProjectNotification.sendBirthdayPushNotification(12892475, birthdayCard: self.selectedImage, message: self.birthdayField.text!)
            }
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            alertController.addTextFieldWithConfigurationHandler({ (textField) in
                textField.textColor = UIColor.blackColor()
                self.birthdayField.text = textField.text
            })
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            let alertView = UIAlertView(title: "Enter Text", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Ok")
            alertView.alertViewStyle = .PlainTextInput
            let textField = alertView.textFieldAtIndex(0)
            birthdayField.text = textField?.text
            alertView.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        print("Selected Image in ok action \(self.selectedImage)")
        PLProjectNotification.sendBirthdayPushNotification((QBSession.currentSession().currentUser?.ID)!, birthdayCard: selectedImage, message: birthdayField.text!)
    }
    
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView)
    {
        let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        self.pageControl.currentPage = Int(currentPage)
        selectedImage = self.pageControl.currentPage
        print("Selected Image in Delegate \(selectedImage)")
    }

    @IBAction func goForward(sender: AnyObject) {

        let pageWidth:CGFloat = CGRectGetWidth(self.scrollView.frame)
        let maxWidth:CGFloat = pageWidth * 4
        let contentOffset:CGFloat = self.scrollView.contentOffset.x
        
        var slideToX = contentOffset + pageWidth
        
        if  contentOffset - pageWidth == maxWidth{
            slideToX = 0
        }
        self.scrollView.scrollRectToVisible(CGRectMake(slideToX, 0, pageWidth, CGRectGetHeight(self.scrollView.frame)), animated: true)
    }
    
    @IBAction func goBackward(sender: AnyObject) {
        let pageWidth:CGFloat = CGRectGetWidth(self.scrollView.frame)
        let maxWidth:CGFloat = pageWidth * 4
        let contentOffset:CGFloat = self.scrollView.contentOffset.x
        
        var slideToX = contentOffset - pageWidth
        
        if  contentOffset - pageWidth == maxWidth{
            slideToX = 0
        }
       self.scrollView.scrollRectToVisible(CGRectMake(slideToX, 0, pageWidth, CGRectGetHeight(self.scrollView.frame)), animated: true)

    }
  
}
