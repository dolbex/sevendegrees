//
//  Buttons.swift
//  SceneKit Tutorial
//
//  Created by Gary Williams on 4/7/16.
//  Copyright © 2016 Gary Williams. All rights reserved.
//

import Foundation
import Cartography

class Buttons {
    
    class func primaryButton(text: String, font: UIFont, alignment: String = "left") -> NavigationButton
    {
        let button: NavigationButton = NavigationButton()
        
        button.setTitle(text.uppercaseString, forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel!.font = font
        button.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0)
        
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = UIColor(red:0.51, green:0.50, blue:0.53, alpha:0.5)
        button.addSubview(bottomBorder)
        
        constrain(bottomBorder) { border in
            border.height == 2
            border.width == border.superview!.width
            border.bottom == border.superview!.bottom
        }
        
        
        button.titleEdgeInsets.left   = 30;
        button.titleEdgeInsets.right  = 30;
        button.titleEdgeInsets.top    = 12;
        button.titleEdgeInsets.bottom = 12;
        
        if alignment == "left" {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        }
        
        if alignment == "right" {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        }
        
        return button
    }
}