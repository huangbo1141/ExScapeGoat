//
//  BaseNavi.swift
//  FYP
//
//  Created by User on 23/11/17.
//  Copyright © 2017 Izisstechnology. All rights reserved.
//

import Foundation
import UIKit

class customNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.shouldRemoveShadow(true)
        self.navigationBar.barTintColor = G_colorBlueLight
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]        
    }
}

extension UINavigationBar {
    
    func shouldRemoveShadow(_ value: Bool) -> Void {
        if value {
            self.setValue(true, forKey: "hidesShadow")
        } else {
            self.setValue(false, forKey: "hidesShadow")
        }
    }
}
