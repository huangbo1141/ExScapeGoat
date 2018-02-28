//
//  Imageview.swift
//  HarvestIT
//
//  Created by Iziss_Technology on 20/07/17.
//  Copyright © 2017 Pankaj Ramchandani & Co. All rights reserved.
//

import Foundation
import UIKit
import PR_utilss

class customUIImageView: UIImageView {
    
    //********************************
    // MARK : IBInspectable
    //********************************
    
    @IBInspectable var roundedCorner : CGFloat = 0.0
        { didSet{ if roundedCorner != 0.0 { self.PR_addCornerRadius(roundedCorner) }}}
    
    @IBInspectable var isRounded : Bool = false
    
    @IBInspectable var customBackgroundColor: Int = 90
        { didSet{ if customBackgroundColor != 90 { self.backgroundColor = helperSubclasses.color(rawValue: customBackgroundColor) } } }
    
    
    
    //********************************
    // MARK : Life Cycle
    //********************************
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if isRounded
        {
            self.clipsToBounds = true
            self.layer.cornerRadius = rect.width / 2
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isRounded
        {
            self.clipsToBounds = true
            self.layer.cornerRadius = self.bounds.width / 2
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
    }
}
