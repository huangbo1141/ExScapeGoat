//
//  PasswordManager.swift
//  MediaHider
//
//  Created by user on 25/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit

/**
 User Password Management :-
 
 This class will handle user password which was require while get in to App.
 
 */

class PasswordManager{
    
    static private var passwordKey : String = "userPassword"
    
    static var isPasswordSetted : Bool
    {
        get { return (UserDefaults.standard.value(forKey: passwordKey) != nil)}
    }
    
    static func set(PasswordOfUser password : String)  {
        UserDefaults.standard.set(password, forKey: passwordKey)
    }
    
    static var getUserPassword : String? {
        get { return UserDefaults.standard.value(forKey: passwordKey) as? String }
    }
    
    static func verifyIsValidPassword(enteredPassword : String) -> Bool {
        if let currentPassword = getUserPassword {
            return (currentPassword == enteredPassword)
        }
        return false
    }
}
