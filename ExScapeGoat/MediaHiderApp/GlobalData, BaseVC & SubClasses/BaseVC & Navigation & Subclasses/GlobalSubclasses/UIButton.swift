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

class customButton: UIButton {
    
    //********************************
    // MARK : Variables
    //********************************
    
    /// If button is used in tableview then we use this for manage data.
    var indexPath : IndexPath? = nil
    
    //********************************
    // MARK : IBInspectable
    //********************************
    
    // Color Realted
    
    @IBInspectable public var clrBlueLight : Bool = false
        { didSet{ if clrBlueLight{ self.backgroundColor = G_colorBlueLight } }}
    
    @IBInspectable public var txtBlueLight : Bool = false
        { didSet{  if txtBlueLight{ self.setTitleColor(G_colorBlueLight, for: .normal )}}}
    
    // END
    
    @IBInspectable var F_Letter : String = "R"
        { didSet{ self.titleLabel?.font = helperSubclasses.font(F_Letter, Size: self.titleLabel?.font.pointSize ?? 0.0) }}
    
    @IBInspectable var fontColor : Int = 90
        { didSet{ if fontColor != 90 { self.setTitleColor( helperSubclasses.color(rawValue: fontColor) , for: .normal)}}}
    
    @IBInspectable var isRounded : Bool = false
    
    @IBInspectable var roundedCorner : CGFloat = 0.0
        { didSet{ if roundedCorner != 0.0 { self.PR_addCornerRadius(roundedCorner) }}}
    
    @IBInspectable var borderWidth : CGFloat = 0.0
        { didSet{ if borderWidth != 0.0 { self.layer.borderWidth = borderWidth }}}
    
    @IBInspectable var borderColor : UIColor = .clear
        { didSet{ if borderColor != .clear { self.layer.borderColor = borderColor.cgColor }}}
    
    @IBInspectable var customBackgroundColor: Int = 90
        { didSet{ if customBackgroundColor != 90 { self.backgroundColor = helperSubclasses.color(rawValue: customBackgroundColor) } } }
    
    @IBInspectable var setBottomLine : Bool = false
        {didSet{ if setBottomLine { self.underlineButtonText() } }}

    //********************************
    // MARK : Defaults
    //********************************
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if isRounded
        {
            self.clipsToBounds = true
            self.layer.cornerRadius = self.bounds.size.width / 2
        }
    }
    
    
    
    //**********************************************************************
    // MARK: Life Cycle
    //**********************************************************************
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
//        self.languagewillMoveToWindow()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        
        
    }
    
    deinit {
        
    }
    
    //**********************************************************************
    // MARK: Language Working
    //**********************************************************************
    
//    
//    var LocalizeState : UIControlState? = nil
//    
//    open func setLocalizeTitle(_ _localizeText : String , state : UIControlState) {
//        
//        self.localizeText = _localizeText; self.LocalizeState = state
//    }
//    
//    @IBInspectable var localizeText : String? = "" {
//        
//        didSet{
//            self.setTitle(localizeText, for: LocalizeState ?? state)
//        }
//    }
//    
//    override func setTitle(_ title: String?, for state: UIControlState) {
//        
//        super.setTitle(title?.localized(using: Localize.currentLanguage()), for: state)
//    }
//    
//    func languagewillMoveToWindow()
//    {
//        setText()
//    }
//    
//    open func setText()
//    {
//        if let localText = self.localizeText, let currentText = self.titleLabel?.text
//        {
//            if localText.localized(using: Localize.currentLanguage()) != currentText
//            {
//                self.localizeText = localText
//            }
//        }
//    }
}


extension UIButton {
    
    private static var expandHitArea : CGFloat = 1.5
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        // if the button is hidden/disabled/transparent it can't be hit
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }
        
        let minimumHitArea = CGSize(width: self.bounds.width + UIButton.expandHitArea, height: self.bounds.height + UIButton.expandHitArea)
        
        // increase the hit frame to be at least as big as `minimumHitArea`
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
        
        // perform hit test on larger frame
        return (largerFrame.contains(point)) ? self : nil
    }
    
    func underlineButtonText()
    {
        self.setAttributedTitle(self.attributedString(), for: .normal)
    }
    
    private func attributedString() -> NSAttributedString? {
        
        if let font = self.titleLabel?.font
        {
            let attributes : [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.font : font,
                NSAttributedStringKey.foregroundColor : UIColor.white,
                NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue
                ]
            let attributedString = NSAttributedString(string: self.currentTitle!, attributes: attributes)
            return attributedString
        }
        return NSAttributedString ()
    }
}







