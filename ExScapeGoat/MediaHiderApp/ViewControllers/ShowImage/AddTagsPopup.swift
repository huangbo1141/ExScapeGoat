//
//  AddTagsPopup.swift
//  ExScapeGoat
//
//  Created by user on 04/03/18.
//  Copyright © 2018 iWazowski.com. All rights reserved.
//

import Foundation
import UIKit

class AddTagsPopup {
    
    static var saveAction : UIAlertAction!
    
    static func showOn(viewController : UIViewController, Handler : @escaping(String) -> ()) {
        
        let alert = UIAlertController.init(title: "Add Tag", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (txtF) in
            txtF.placeholder = "Enter Tag"
            txtF.addTarget(self, action: #selector(textChanged(txtF:)), for: .editingChanged)
        })
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil))
        
        saveAction = UIAlertAction.init(title: "Save", style: .default, handler: { (_ ) in
            if let txtF = alert.textFields?.first {
                Handler(txtF.text!)
            }
        })
        
        saveAction.isEnabled = false
        
        alert.addAction(saveAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    @objc static func textChanged(txtF : UITextField) {
        
        saveAction.isEnabled = !txtF.text!.PR_isEmpty
        
        if txtF.text!.count > 10 {
            txtF.text?.removeLast()
        }
    }
}
