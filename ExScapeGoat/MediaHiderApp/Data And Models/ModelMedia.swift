//
//  ModelMedia.swift
//  MediaHider
//
//  Created by user on 28/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import RealmSwift

class ModelMedia : Object {
    
    @objc dynamic var encryptedNameOfItem : Data!
    @objc dynamic var password : String = ""
    @objc dynamic var isVideo : Bool = false
    
    /// Needed for iClould
    @objc dynamic var isUploaded : Bool = false
    @objc dynamic var isUpdated : Bool = false
    @objc dynamic var iclouldIdentifier : String = ""
    /// END
    
    /// Tags
    /// Values are in comma seperated
    @objc dynamic var tags : String = ""
    
    var isSelected = false
    
    override static func primaryKey() -> String?
    {
        return "password"
    }
}
