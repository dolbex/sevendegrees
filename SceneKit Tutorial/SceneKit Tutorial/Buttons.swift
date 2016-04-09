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
        button.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.3)
        
        button.titleEdgeInsets.left   = 30;
        button.titleEdgeInsets.right  = 30;
        button.titleEdgeInsets.top    = 15;
        button.titleEdgeInsets.bottom = 15;
        
        if alignment == "left" {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        }
        
        if alignment == "right" {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        }
        
        return button
    }
}