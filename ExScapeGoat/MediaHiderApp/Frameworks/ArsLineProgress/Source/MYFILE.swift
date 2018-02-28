

import Foundation
import UIKit


extension  UIViewController
{
    public func LoaderShowArs(withLblText String: String = "" , withProgress initialeValue : CGFloat = 0.0 )
    {
        guard let keywindow  = UIApplication.shared.keyWindow else { return }
        
        guard let rootView  = keywindow.rootViewController?.view else { return }
        
        let v = UIView(frame: CGRect(x: 0, y: 0, width: rootView.frame.width, height: rootView.frame.height * 0.8))
        
        rootView.addSubview(v)
        
        let lbl = UILabel(frame: CGRect(x: 0, y: v.frame.midY + 60 , width: rootView.frame.size.width, height: 50))
        
        v.addSubview(lbl)
        
        lbl.tag = 45501
        
        lbl.textColor = .black
        
        lbl.textAlignment = .center
        
        lbl.text = String
        
        
        if initialeValue != 0.0
        {
            ARSLineProgress.showWithProgress(initialValue: initialeValue,  onView: v)
            
            LoaderUpdateProgress(initialeValue * 0.2)
        }
        else
        {
            ARSLineProgress.ars_showOnView(v)
        }
    }
    
    public func LoaderUpdateProgress(_ value : CGFloat ,_ text : String = "")
    {
        guard let rootView  = UIApplication.shared.keyWindow?.rootViewController?.view else { return }
        
        if text != ""
        {
            if let lbl = rootView.viewWithTag(45501) as? UILabel
            {
                lbl.text = text
            }
        }
        
        ARSLineProgress.updateWithProgress(value)
    }
    
    public enum status
    {
        case success
        case failure
    }
    
    public func LoaderHideArs(_ status : status , _ message : String = "")
    {
        guard let rootView  = UIApplication.shared.keyWindow?.rootViewController?.view else { return }
        
        if let lbl = rootView.viewWithTag(45501) as? UILabel
        {
            if message != ""
            {
                lbl.text = message
                
                if status == .success
                {
                    ARSLineProgress.showSuccess()
                    
                }
                else if status == .failure
                {
                    ARSLineProgress.showFail()
                    
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500) , execute: {
                                        
                    lbl.removeFromSuperview()
                })
                
                return
            }
            else
            {
                lbl.removeFromSuperview()
            }
        }
        
        if status == .success
        {
            ARSLineProgress.showSuccess()
        }
        else if status == .failure
        {
            ARSLineProgress.showFail()
        }
    }
}
