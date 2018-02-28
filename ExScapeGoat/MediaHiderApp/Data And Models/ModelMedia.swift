//
//  ModelMedia.swift
//  MediaHider
//
//  Created by user on 28/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import RealmSwift

class ModelMedia : Object
{
    @objc dynamic var encryptedNameOfItem : Data!
    @objc dynamic var password : String = ""
    @objc dynamic var isVideo : Bool = false
    
    var isSelected = false
    
    override static func primaryKey() -> String?
    {
        return "password"
    }
}
