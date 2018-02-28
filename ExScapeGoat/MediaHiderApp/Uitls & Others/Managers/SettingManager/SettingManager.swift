//
//  SettingManager.swift
//  ExScapeGoat
//
//  Created by q on 2/10/18.
//  Copyright © 2018 iWazowski.com. All rights reserved.
//

import Foundation
import UIKit

class SettingManager{
    
    static private var bgKey : String = "backgroundSetting"
    static private var iconKey : String = "iconSetting"
    
    static var isBackgroundSetted : Bool
    {
        get { return (UserDefaults.standard.value(forKey: bgKey) != nil)}
    }
    
    static func set(BackgroundIndex index : String)  {
        UserDefaults.standard.set(index, forKey: bgKey)
    }
    
    static var getBackgroundIndex : String? {
        get { return UserDefaults.standard.value(forKey: bgKey) as? String }
    }
    
    static func verifyIsValidBackground(enteredIndex : String) -> Bool {
        if let currentIndex = getBackgroundIndex {
            return (currentIndex == enteredIndex)
        }
        return false
    }
    
    static var isIconSetted : Bool
    {
        get { return (UserDefaults.standard.value(forKey: iconKey) != nil)}
    }
    
    static func set(IconIndex index : String)  {
        UserDefaults.standard.set(index, forKey: iconKey)
    }
    
    static var getIconIndex : String? {
        get { return UserDefaults.standard.value(forKey: iconKey) as? String }
    }
    
    static func verifyIsValidIcon(enteredIndex : String) -> Bool {
        if let currentIndex = getIconIndex {
            return (currentIndex == enteredIndex)
        }
        return false
    }
}
