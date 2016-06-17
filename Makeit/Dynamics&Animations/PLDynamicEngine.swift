//
//  PLDynamicEngine.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 19/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import Foundation
import UIKit

class PLDynamicEngine{

//Profile Pic Animations (UIImageView)

//1. Profile Pic Scaling Animation allows user profile picture growing forward from its lowest shrink

    static func viewGrowingFromShrinkAnimation(view:UIView){
    
    UIView.animateWithDuration(1.0, animations: {() -> Void in
     view.transform = CGAffineTransformMakeScale(0.0, 0.0)
     }, completion: {(finished: Bool) -> Void in
     UIView.animateWithDuration(1.0, animations: {() -> Void in
     view.transform = CGAffineTransformMakeScale(1, 1)
     })
     })
    
    }

//2. Profile Pic Bouncing Animatin
    
    static func viewBouncingAnimation(view:UIView){
        
        let origin:CGPoint = view.center
        let target:CGPoint = CGPointMake(origin.x, origin.y+30)
        let bounce = CABasicAnimation(keyPath: "position.y")
        bounce.duration = 0.5
        bounce.fromValue = origin.y
        bounce.toValue = target.y
        bounce.repeatCount = 2
        bounce.autoreverses = true
        view.layer.addAnimation(bounce, forKey: "position")
    }
    
//3. Profile Pic Flip Animation
    
    static func flipViewWithAnimation(view:UIView){
        
        UIView.transitionWithView(view, duration:2, options: .TransitionFlipFromTop, animations: {() -> Void in
            //  Set the new image
            //  Since its done in animation block, the change will be animated
            
            }, completion: {(finished: Bool) -> Void in
                //  Do whatever when the animation is finished
        })
    }
   
 //4. Profile Pic Animation Appearance from space
    
    static func magicAppearanceAnimation(view:UIView){
        
        view.frame = CGRectMake(-50, view.frame.origin.y,view.frame.size.width, view.frame.size.height)
         
         UIView.animateWithDuration(0.9, animations: {() -> Void in
         
         view.frame = CGRectMake(20, view.frame.origin.y, view.frame.size.width, view.frame.size.height)
         
       })
   }

  //5. Profile Pic shake Animation
    
    static func shakeViewAnimation(view:UIView){
        
        let animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 1.0
        animation.values = [-20, 20, -20, 20, -10, 10, -5, 5, 0]
        view.layer.addAnimation(animation, forKey: "shake")
    }
    
    // Random Animator Generator
    static func randomAnimationGeneratorForProfilePic()->(view:UIView)->Void{
        
        let random = Int(arc4random_uniform(5))
        
        switch random {
        case 0:
            return PLDynamicEngine.viewGrowingFromShrinkAnimation
        case 1:
            return PLDynamicEngine.viewBouncingAnimation
        case 2:
            return PLDynamicEngine.flipViewWithAnimation
        case 3:
            return PLDynamicEngine.shakeViewAnimation
        default:
            return PLDynamicEngine.magicAppearanceAnimation
        }
    }

    
//3. Tableviewcells Anmation
    
    // Bottom to top animation with bouncing
    
    static func bottomToTopAnimationWithBouncing(view: UIView, cell:UITableViewCell)
    {
        cell.frame = CGRectMake(view.frame.size.width, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)
        UIView.animateWithDuration(0.4) {
            cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)
    }
    }
    
    //Expanding cell from middle with 3D calling
    
    static func expandCellsFromMiddleWith3D(cells : [UITableViewCell])
    {
        for cell in cells
        {
            cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
            UIView.animateWithDuration(0.5, animations: {
                cell.layer.transform = CATransform3DMakeScale(1,1,1)
            })
        }
    }

    //Right to Left Animation
    static func rightToLeftAnimation(cells : [UITableViewCell],tableHeight: CGFloat)
    {        
        for i in cells
        {
            let cell = i as UITableViewCell
            cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
        }
        
        var index = 0
        
        for a in cells
        {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0);
                }, completion: nil)
            
            index += 1
        }
    }
    
       
}
    
    
