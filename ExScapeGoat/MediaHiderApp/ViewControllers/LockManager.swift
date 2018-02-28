//
//  LockManager.swift
//  ExScapeGoat
//
//  Created by BoHuang on 2/22/18.
//  Copyright © 2018 iWazowski.com. All rights reserved.
//

import Foundation

class LockManager:NSObject,PasswordInputCompleteProtocol {
    
    var passwordContainerView = PasswordContainerView.initMe(withDigit: 6)
    let fullScreenView = UIView()
    var view:UIView = UIView()
    @objc public func setupView(view:UIView) {
        self.view = view
        if let view = fullScreenView.superview {
            fullScreenView.removeFromSuperview()
        }
        if let view = passwordContainerView.superview {
            passwordContainerView.removeFromSuperview()
        }
        
        passwordContainerView = PasswordContainerView.initMe(withDigit: 6)
        fullScreenView.backgroundColor = UIColor.white;
        self.setupPasswordContainerView()
    }
    
    func setupPasswordContainerView() {
        
        passwordContainerView.tintColor = G_colorBlueLight
        passwordContainerView.highlightedColor = G_colorBlueLight
        passwordContainerView.delegate = self
        
        self.view.addSubview(fullScreenView)
        fullScreenView.addSubview(passwordContainerView)
        
        fullScreenView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([NSLayoutConstraint.init(item: fullScreenView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0),
        NSLayoutConstraint.init(item: fullScreenView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0),
        NSLayoutConstraint.init(item: fullScreenView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0),
        NSLayoutConstraint.init(item: fullScreenView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1, constant: 0)])
        
        passwordContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.fullScreenView.addConstraints([NSLayoutConstraint.init(item: passwordContainerView, attribute: .centerX, relatedBy: .equal, toItem: self.fullScreenView, attribute: .centerX, multiplier: 1.0, constant: 0),
          NSLayoutConstraint.init(item: passwordContainerView, attribute: .centerY, relatedBy: .equal, toItem: self.fullScreenView, attribute: .centerY, multiplier: 1.0, constant: 0),
          NSLayoutConstraint.init(item: passwordContainerView, attribute: .width, relatedBy: .equal, toItem: self.fullScreenView, attribute: .width, multiplier: 0.7, constant: 0),
          NSLayoutConstraint.init(item: passwordContainerView, attribute: .height, relatedBy: .equal, toItem: self.fullScreenView, attribute: .height, multiplier: 0.65, constant: 0)])
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        
        if success
        {
            self.fullScreenView.removeFromSuperview()
        }
    }
    
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        
        if PasswordManager.verifyIsValidPassword(enteredPassword: input)
        {
            // when login success
            self.fullScreenView.removeFromSuperview()
        }
        else
        {
            Banner.customBannerShow(title: "Error", subtitle: "Please enter a valid password", colorCase: .error)
            passwordContainerView.wrongPassword()
        }
    }
}
