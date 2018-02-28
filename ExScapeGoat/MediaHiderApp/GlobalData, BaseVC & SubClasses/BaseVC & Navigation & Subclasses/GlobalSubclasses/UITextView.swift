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

class customTextView: UITextView , UITextViewDelegate {
    
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
        { didSet{ self.font = helperSubclasses.font(F_Letter, Size: self.font?.pointSize ?? 0.0 )}}
    
    @IBInspectable var fontColor : Int = 90
        { didSet{ if fontColor != 90 { self.textColor =  helperSubclasses.color(rawValue: fontColor) }}}
    
    @IBInspectable var paddingSize : CGSize = CGSize(width: 0.0, height: 0.0)
        { didSet{ if paddingSize != CGSize(width: 0.0, height: 0.0) { self.textContainerInset = UIEdgeInsetsMake(paddingSize.height, paddingSize.width, paddingSize.height, paddingSize.width) } } }
    
    @IBInspectable var roundedCorner : CGFloat = 0.0
        { didSet{ if roundedCorner != 0.0 { self.PR_addCornerRadius(roundedCorner) }}}
    
    @IBInspectable var customBackgroundColor: Int = 90
        { didSet{ if customBackgroundColor != 90 { self.backgroundColor = helperSubclasses.color(rawValue: customBackgroundColor) } } }
    
    @IBInspectable var borderWidth : CGFloat = 0.0
        { didSet{ if borderWidth != 0.0 { self.layer.borderWidth = borderWidth }}}
    
    @IBInspectable var borderColor : UIColor = .clear
        { didSet{ if borderColor != .clear { self.layer.borderColor = borderColor.cgColor }}}
    
    
    @IBInspectable var placeHolderText : String = ""
        {
        didSet{
            
            if placeHolderText != ""
            {
                delegate = self
                
                self.text = placeHolderText
                self.textColor = placeHolderColor
            }
        }
    }
    
    @IBInspectable var placeHolderColor = UIColor.lightGray.withAlphaComponent(0.8)
    
    
    override var text: String!
    {
        get{ if self.textColor == placeHolderColor { return ""} else { return super.text } }
        set(newValue){ super.text = newValue; if self.textColor == placeHolderColor { self.textColor = .black } }
    }
    
    //**********************************************************************
    // MARK: PlaceHolderWorking
    //**********************************************************************
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if self.textColor == placeHolderColor
        {
            self.textColor = .black
            self.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if self.text.isEmpty
        {
            self.text = placeHolderText
            self.textColor = placeHolderColor
        }
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
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
//        self.languageWillMoveToWindow()
    }
    
    deinit {
        
    }
    
//    //**********************************************************************
//    // MARK: Language Working
//    //**********************************************************************
//    
//    @IBInspectable var localizeText : String?{
//        
//        willSet(newValue){
//            if let txt = newValue
//            {
//                self.text = txt.localized(using: Localize.currentLanguage())
//            }
//        }
//    }
//    
//    @IBInspectable var localizePlaceholder : String? {
//        
//        willSet(newValue){
//            if let txt = newValue
//            {
//                self.placeHolderText = txt.localized(using: Localize.currentLanguage())
//            }
//        }
//    }
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
//        
//        if let localText = self.localizePlaceholder
//        {
//            let currentText = self.placeHolderText
//            
//            
//            if localText.localized(using: Localize.currentLanguage()) != currentText
//            {
//                self.localizePlaceholder = localText
//            }
//        }
//    }
}
