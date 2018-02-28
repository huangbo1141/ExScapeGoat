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

class customTextField: UITextField  {
    
    //**********************************************************************
    // MARK: IBInspectable
    //**********************************************************************
    
    // Color Realted
    
    @IBInspectable public var clrBlueLight : Bool = false
        { didSet{ if clrBlueLight{ self.backgroundColor = G_colorBlueLight } }}
    
    @IBInspectable public var txtBlueLight : Bool = false
        { didSet{  if txtBlueLight{ self.textColor = G_colorBlueLight }}}
    
    // END
    
    @IBInspectable open var task : Int = 0
    
    @IBInspectable open var limit : Bool = false
    
    @IBInspectable var limitSize : Int = 0
    
    @IBInspectable var isCustomInteractionEnable : Bool = false
        { didSet{ if isCustomInteractionEnable { delegate = self }}}
    
    @IBInspectable var F_Letter : String = "R"
        { didSet{ self.font = helperSubclasses.font(F_Letter, Size: self.font?.pointSize ?? 0.0 )}}
    
    @IBInspectable var fontColor : Int = 90
        { didSet{ if fontColor != 90 { self.textColor =  helperSubclasses.color(rawValue: fontColor) }}}
    
    @IBInspectable var placeholderColor : UIColor?
        { didSet{ if let clr = placeholderColor { self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: clr]) }}}
    
    @IBInspectable var paddingSize : CGFloat = 0.0
    
    @IBInspectable var roundedCorner : CGFloat = 0.0
        { didSet{ if roundedCorner != 0.0 { self.PR_addCornerRadius(roundedCorner) }}}
    
    
    @IBInspectable var borderWidth : CGFloat = 0.0
        { didSet{ if borderWidth != 0.0 { self.layer.borderWidth = borderWidth }}}
    
    @IBInspectable var borderColor : UIColor = .clear
        { didSet{ if borderColor != .clear { self.layer.borderColor = borderColor.cgColor }}}
    
    @IBInspectable var customBackgroundColor: Int = 90
        { didSet{ if customBackgroundColor != 90 { self.backgroundColor = helperSubclasses.color(rawValue: customBackgroundColor) } } }
    
    @IBInspectable var rightImage : UIImage?
        { didSet{ if rightImage != nil { setImage() }  } }
    
    
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
        
        if task != 0
        {
            delegate = self
        }
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        //        self.languageWillMoveToWindow()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + paddingSize, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + paddingSize, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    deinit {
        
    }
    
    // MARK:- Custom Funtions
    
    func setImage(){
        let imgV = UIImageView(frame: CGRect(x: 0, y: 0, width: self.bounds.height, height: self.bounds.height))
        imgV.image = rightImage
        imgV.contentMode = .scaleAspectFit
        self.rightView = imgV
        self.rightViewMode = .always
    }
    
    
    //**********************************************************************
    // MARK: Language Working
    //**********************************************************************
    
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
    //
    //    @IBInspectable var localizePlaceholder : String? {
    //
    //        willSet(newValue){
    //            if let txt = newValue
    //            {
    //                self.placeholder = txt.localized(using: Localize.currentLanguage())
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
    //
    //        if let localText = self.localizePlaceholder, let currentText = self.placeholder
    //        {
    //            if localText.localized(using: Localize.currentLanguage()) != currentText
    //            {
    //                self.localizePlaceholder = localText
    //            }
    //        }
    //    }
}

// MARK: Disable Copy
extension customTextField
{
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if task == 4
        {
            if action == #selector(copy(_:))
            {
                return false
            }
        }
        
        return super.canPerformAction(action, withSender: sender)
        
    }
}


extension customTextField : UITextFieldDelegate
{
    /**
     Handling interaction for such a dropdown type textField
     */
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return !isCustomInteractionEnable
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if string.characters.count > 1
        {
           return true
        }
        
        let char = string.cString(using: String.Encoding.utf8)!
        
        let isBackSpace = strcmp(char, "\\b")
        
        if limit
        {
            if isBackSpace == -92
            {
                
            }
            else
                if (self.text?.characters.count)! >= limitSize
                {
                    return false
            }
        }
        
        if (isBackSpace == -92)
        {
            print("Backspace was pressed")
        }
        else
        {
            switch task
            {
            case 0 :
                
                return true
                
            case 1 :  // Mobile Number
                
                
                let arr = ["0","1","2","3","4","5","6","7","8","9","0","+"," "]
                
                if !arr.contains(string)
                {
                    return false
                }
                
            case 2  :          // Only Allow Number
                
                let arr = ["0","1","2","3","4","5","6","7","8","9","0"]
                
                if !arr.contains(string)
                {
                    return false
                }
                
                
            case 3   :         // Only Allow Character
                
                let arr = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"," "]
                
                var isVaild = false
                
                for i in arr
                {
                    if i.uppercased() == string.uppercased()
                    {
                        isVaild = true
                        
                        break
                    }
                }
                
                return isVaild
                
            case 4:       // Password
                
                return string != " "
                
            case 5: // Email
                
                if textField.text!.contains("@")
                {
                    if string.contains("@")
                    {
                        return false
                    }
                }
                
                let arr = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9","0","-","_","@"," ", "."]
                
                var isVaild = false
                
                for i in arr
                {
                    if i.uppercased() == string.uppercased()
                    {
                        isVaild = true
                        
                        break
                    }
                }
                
                
                return isVaild
                
            default :
                print("")
            }
        }
        
        return true
    }
}







