//
//  CreatePassword.swift
//  MediaHider
//
//  Created by user on 24/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit

class createPassword  : baseVc {
    
    //*********************************************
    // MARK: Variables
    //*********************************************
    
    //*********************************************
    // MARK: Outlets
    //*********************************************
    
    @IBOutlet weak var txtFEnterPassword: UITextField!
    
    @IBOutlet weak var txtFConfirmPassword: UITextField!
    
    //*********************************************
    // MARK: Defaults
    //*********************************************
    
    public var mode:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.mode == 0 {
            if PasswordManager.isPasswordSetted
            {
                if let vc = G_getVc(ofType: login(), FromStoryBoard: storyBoards.main , withIdentifier: vcIdentifiers.Login)
                {
                    self.navigationController?.pushViewController(vc, animated: false)
                    
                    return;
                }
            }
        }
        
        self.addDoneButtonOnKeyboard()
        self.txtFEnterPassword.becomeFirstResponder()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(createPassword.doneButtonAction(_:)))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.txtFConfirmPassword.inputAccessoryView = doneToolbar
        self.txtFEnterPassword.inputAccessoryView = doneToolbar
    }
    
    @objc open func doneButtonAction(_ sender: UIView)
    {
        self.view.endEditing(true)
    }
}


//*********************************************
// MARK: Actions
//*********************************************

extension createPassword
{
    /**
     #selectors
     */
    
    
    /**
     @IBActions
     */
    
    @IBAction func btnSubmit(_ sender : AnyObject)
    {
        if txtFConfirmPassword.text?.PR_isEmpty == true || txtFEnterPassword.text?.PR_isEmpty == true
        {
            Banner.customBannerShow(title: "Error", subtitle: "All Fields are mendatory.", colorCase: .error)
            return
        }
        
        if txtFConfirmPassword.text!.count != 6 || txtFEnterPassword.text!.count != 6
        {
            Banner.customBannerShow(title: "Error", subtitle: "Password length should be 6 characters", colorCase: .error)
            return
        }
        
        if txtFEnterPassword.text != txtFConfirmPassword.text
        {
            Banner.customBannerShow(title: "Error", subtitle: "Password and Confirm Password are not equal.", colorCase: .error)
            return;
        }
        
        if self.mode == 0 {
            if let vc = G_getVc(ofType: desktopVC(), FromStoryBoard: storyBoards.main , withIdentifier: vcIdentifiers.desktopVC)
            {
                /// Setting password to local.
                PasswordManager.set(PasswordOfUser: self.txtFConfirmPassword.text!)
                
                /// Sucess message
                Banner.customBannerShow(title: "Success", subtitle: "Password updated successfully", colorCase: .success)
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            PasswordManager.set(PasswordOfUser: self.txtFConfirmPassword.text!)
            Banner.customBannerShow(title: "Success", subtitle: "Password updated successfully", colorCase: .success)
            self.navigationController?.popViewController(animated: true)
        }
        
        
        
        
    }
}


//*********************************************
// MARK: Custom Methods
//*********************************************

extension createPassword
{
    
}


