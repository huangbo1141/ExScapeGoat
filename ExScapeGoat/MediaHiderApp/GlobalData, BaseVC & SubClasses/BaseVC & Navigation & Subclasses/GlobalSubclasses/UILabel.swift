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

class customLabel: UILabel {
    
    //**********************************************************************
    // MARK: IBInspectable
    //**********************************************************************
    
    // Color Realted
    
    @IBInspectable public var clrBlueLight : Bool = false
        { didSet{ if clrBlueLight{ self.backgroundColor = G_colorBlueLight } }}
    
    @IBInspectable public var txtBlueLight : Bool = false
        { didSet{  if txtBlueLight{ self.textColor = G_colorBlueLight }}}
    
    // END
    
    @IBInspectable var F_Letter : String = "R"
        { didSet{ self.font = helperSubclasses.font(F_Letter, Size: self.font.pointSize)}}
    
    @IBInspectable var fontColor : Int = 90
        { didSet{ if fontColor != 90 { self.textColor =  helperSubclasses.color(rawValue: fontColor) }}}
    
    @IBInspectable var roundedCorner : CGFloat = 0.0
        { didSet{ if roundedCorner != 0.0 { self.PR_addCornerRadius(roundedCorner) }}}
    
    @IBInspectable var isRounded : Bool = false

    @IBInspectable var borderWidth : CGFloat = 0.0
        { didSet{ if borderWidth != 0.0 { self.layer.borderWidth = borderWidth }}}
    
    @IBInspectable var borderColor : UIColor = .clear
        { didSet{ if borderColor != .clear { self.layer.borderColor = borderColor.cgColor }}}
    
    @IBInspectable var customBackgroundColor: Int = 90
        { didSet{ if customBackgroundColor != 90 { self.backgroundColor = helperSubclasses.color(rawValue: customBackgroundColor) } } }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //**********************************************************************
    // MARK: Life Cycle
    //**********************************************************************
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
//        self.languageWillMoveToWindow()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isRounded
        {
            self.clipsToBounds = true
            self.layer.cornerRadius = self.bounds.size.width / 2
        }
    }
    
    deinit {
        
    }
    
    //**********************************************************************
    // MARK: Language Working
    //**********************************************************************
    
//    @IBInspectable var localizeText : String?{
//        
//        willSet(newValue){
//            if let txt = newValue
//            {
//               self.text = txt.localized(using: Localize.currentLanguage())
//            }
//        }
//    }
//    
//    
//    func languageWillMoveToWindow()
//    {
//        if let localText = self.localizeText, let currentText = self.text
//        {
//            if localText.localized(using: Localize.currentLanguage()) != currentText
//            {
//                self.localizeText = localText
//            }
//        }
//    }
}
