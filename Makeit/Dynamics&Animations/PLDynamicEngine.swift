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

}