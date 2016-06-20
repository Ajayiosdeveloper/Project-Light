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
    
    //4. Tableviewcell Animation
    class func animateCell(cell: UITableViewCell, withTransform transform: (CALayer) -> CATransform3D, andDuration duration: NSTimeInterval) {
        
        let view = cell.contentView
        view.layer.transform = transform(cell.layer)
        view.layer.opacity = 0.8
        
        UIView.animateWithDuration(duration) {
            view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1
        }
    }
    
    //Various Cell animation properties
    
    static let TransformTipIn = { (layer: CALayer) -> CATransform3D in
        let rotationDegrees: CGFloat = -15.0
        let rotationRadians: CGFloat = rotationDegrees * (CGFloat(M_PI)/180.0)
        let offset = CGPoint(x: -20, y: -20)
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, rotationRadians, 0.0, 0.0, 1.0)
        transform = CATransform3DTranslate(transform, offset.x, offset.y, 0.0)
        
        return transform
    }
    
    static let TransformCurl = { (layer: CALayer) -> CATransform3D in
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -500
        transform = CATransform3DTranslate(transform, -layer.bounds.size.width/2.0, 0.0, 0.0)
        transform = CATransform3DRotate(transform, CGFloat(M_PI)/2.0, 0.0, 1.0, 0.0)
        transform = CATransform3DTranslate(transform, layer.bounds.size.width/2.0, 0.0, 0.0)
        
        return transform
    }
    
    static let TransformFan = { (layer: CALayer) -> CATransform3D in
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, -layer.bounds.size.width/2.0, 0.0, 0.0)
        transform = CATransform3DRotate(transform, -CGFloat(M_PI)/2.0, 0.0, 0.0, 1.0)
        transform = CATransform3DTranslate(transform, layer.bounds.size.width/2.0, 0.0, 0.0)
        return transform
    }
    
    static let TransformFlip = { (layer: CALayer) -> CATransform3D in
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0.0, layer.bounds.size.height/2.0, 0.0)
        transform = CATransform3DRotate(transform, CGFloat(M_PI)/2.0, 1.0, 0.0, 0.0)
        transform = CATransform3DTranslate(transform, 0.0, layer.bounds.size.height/2.0, 0.0)
        return transform
    }
    
    static let TransformHelix = { (layer: CALayer) -> CATransform3D in
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0.0, layer.bounds.size.height/2.0, 0.0)
        transform = CATransform3DRotate(transform, CGFloat(M_PI), 0.0, 1.0, 0.0)
        transform = CATransform3DTranslate(transform, 0.0, -layer.bounds.size.height/2.0, 0.0)
        return transform
    }
    
    static let TransformTilt = { (layer: CALayer) -> CATransform3D in
        var transform = CATransform3DIdentity
        transform = CATransform3DScale(transform, 0.8, 0.8, 0.8)
        return transform
    }
    
    static let TransformWave = { (layer: CALayer) -> CATransform3D in
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, -layer.bounds.size.width/2.0, 0.0, 0.0)
        return transform
    }
    
    //Animation of Views
    class func animateView(view: UIView, withTransform transform: (CALayer) -> CATransform3D, andDuration duration: NSTimeInterval) {
        
        view.layer.transform = transform(view.layer)
        view.layer.opacity = 0.8
        
        UIView.animateWithDuration(duration) {
            view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1
        }
    }

    //5.TextField Animation
    
    static func animateTextfield(textField:UITextField)
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.2
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(textField.center.x - 10, textField.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(textField.center.x + 10, textField.center.y))
        textField.layer.addAnimation(animation, forKey: "position")
   
    }
    
    //6.Animate Button
    
    static func animateButton(button : UIButton)
    {
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            button.bounds = CGRect(x: button.bounds.origin.x - 20, y: button.bounds.origin.y, width: button.bounds.size.width + 60, height: button.bounds.size.height)}, completion: nil)
    }
    
}
    
    
