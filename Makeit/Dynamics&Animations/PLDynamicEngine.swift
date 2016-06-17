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