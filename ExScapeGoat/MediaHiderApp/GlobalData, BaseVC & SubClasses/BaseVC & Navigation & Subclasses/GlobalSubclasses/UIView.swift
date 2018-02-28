//
//  customLabel.swift
//  HarvestIT
//
//  Created by Iziss_Technology on 20/07/17.
//  Copyright © 2017 Pankaj Ramchandani & Co. All rights reserved.
//

import Foundation
import UIKit
import PR_utilss

class customView: UIView {
    
    // Color Realted
    
    @IBInspectable public var clrBlueLight : Bool = false
        { didSet{ if clrBlueLight{ self.backgroundColor = G_colorBlueLight } }}
    
    // END
    
    @IBInspectable var roundedCorner : CGFloat = 0.0
        { didSet{ if roundedCorner != 0.0 { self.PR_addCornerRadius(roundedCorner) }}}
    
    @IBInspectable var isRounded : Bool = false
    
    @IBInspectable var borderWidth : CGFloat = 0.0
        { didSet{ if borderWidth != 0.0 { self.layer.borderWidth = borderWidth }}}
    
    @IBInspectable var borderColor : UIColor = .clear
        { didSet{ if borderColor != .clear { self.layer.borderColor = borderColor.cgColor }}}
    
    @IBInspectable var customBackgroundColor: Int = 90
        { didSet{ if customBackgroundColor != 90 { self.backgroundColor = helperSubclasses.color(rawValue: customBackgroundColor) } } }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if isRounded
        {
            self.clipsToBounds = true
            self.layer.cornerRadius = self.bounds.size.width / 2
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
    }
}
