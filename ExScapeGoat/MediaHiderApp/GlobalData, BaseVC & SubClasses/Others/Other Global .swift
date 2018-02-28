//
//  Others Global.swift
//  FYP
//
//  Created by User on 22/11/17.
//  Copyright © 2017 Izisstechnology. All rights reserved.
//

import Foundation
import UIKit
import PR_utilss


// MARK: Global Declairation

typealias PR_JSON = JSON


// MARK: VC Identifier

/// This helps to get vc from stoaryboard
func G_getVc<T>(ofType : T, FromStoryBoard : storyBoards , withIdentifier : vcIdentifiers) -> T? where T : UIViewController {
    
    if let vc = UIStoryboard.init(name: FromStoryBoard.rawValue, bundle: nil).instantiateViewController(withIdentifier: withIdentifier.rawValue) as? T
    {
        return vc
    }
    
    return nil
}

enum vcIdentifiers : String {
    case Login = "login"
    case CreatePassword = "createPassword"
    case TabBaseVc = "TabBaseViewController"
    case home = "home"
    case ShowImage = "ShowImage"
    case desktopVC = "desktopVC"
    case HeySplash = "QMSplashViewController"
    case HeyNavChat = "NavChat"
    case HeyNavContacts = "NavContacts"
    case HeyNavAuth = "NavAuth"
    case HeyNavSplit = "NavSplit"
    case changeBackVC = "changeBackVC"
    case settingVC = "settingVC"
    case settingNav = "settingNav"
    case changeAppIconVC = "changeAppIconVC"
}

// MARK: StoaryBoards

enum storyBoards : String {
    case main = "MainMedia"
    case start = "Start"
    case mainMessage = "Main"
    case auth = "Auth"
}

/**
 Showing loader by here
 */

let loader = ARSInfiniteLoader()

func G_loaderShow()
{
    G_threadMain {
        
        var vc : UIViewController!
        
        if let navi = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        {
            vc = navi.topViewController
        }
        else
        {
            vc = UIApplication.shared.keyWindow?.rootViewController
        }
        
        PR_Ext.userInterection(false)
        
        loader.ars_showOnView( vc.view, completionBlock: nil)
    }
}

func G_loaderHide()
{
    G_threadMain {
        
        PR_Ext.userInterection(true)
        
        loader.backgroundBlurView.removeFromSuperview()
        loader.backgroundFullView.removeFromSuperview()
        loader.backgroundSimpleView.removeFromSuperview()
        
        loader.emptyView.removeFromSuperview()
        ars_currentLoader = nil
        ars_currentCompletionBlock = nil
    }
}


//********************************************************
// MARK: Queue's
//********************************************************

func G_threadMain(_ execute : @escaping() -> ()) {
    
    if Thread.isMainThread
    {
        execute()
    }
    else
    {
        DispatchQueue.main.async { execute() }
    }
}

func G_threadBackground(_ execute : @escaping() -> ()) {
    
    if Thread.isMainThread
    {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { execute() }
    }
    else
    {
        execute()
    }
}
