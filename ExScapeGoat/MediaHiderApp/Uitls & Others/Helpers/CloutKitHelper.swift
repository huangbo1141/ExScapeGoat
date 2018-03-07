//
//  CloutKitHelper.swift
//  ExScapeGoat
//
//  Created by user on 07/03/18.
//  Copyright © 2018 iWazowski.com. All rights reserved.
//

import Foundation
import UIKit

/// Media Keys
enum mediaKeys : String {
    case picture = "picture"
    case pictureName = "pictureName"
    case tags = "tags"
}

/// Notes Keys
enum notesKeys : String {
    case desc = "desc"
}

/// Helper model

struct iClouldMediaModel {
    var image : Data!
    var imageName : String!
    var identifier : String!
    var tags : String!
}

/// Helper funtions

struct clouldKitHelper {
    
    static func syncPhotosWithiClould() {
        
        if let notUploadedModel = PR_RealmManager.Fetch(realmArray: ModelMedia.self).first(where: { return ($0.isVideo == false && $0.isUploaded == false) }) {
         
            do {
                
                let passwordForMedia : String = notUploadedModel.password
                
                let originalData = try RNCryptor.decrypt(data: notUploadedModel.encryptedNameOfItem, withPassword: passwordForMedia)
                
                let nameFromData = String.init(data: originalData, encoding: String.Encoding.utf8)!
                
                if let dataAndURL = photosManager.fetchItem(ofType: .photos, withName: nameFromData)
                {
                    let imgData = dataAndURL.0
                    
                    let dic : [String : Any] = [mediaKeys.picture.rawValue : imgData,
                                                mediaKeys.tags.rawValue : notUploadedModel.tags,
                                                mediaKeys.pictureName.rawValue : nameFromData]
                    
                    CloudKitManager.createRecord(ofMediaType: recordType.media, dic) { (record, error) in
                        print(record)
                        if error == nil {
                            G_realmBeginWrite()
                            notUploadedModel.isUploaded = true
                            notUploadedModel.iclouldIdentifier = record!.recordID.recordName
                            G_realmCommitWrite(errorIn: "change uploading status")
                            
                            self.syncPhotosWithiClould()
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("All Completed")
        }
    }
    
    static func updateTagsOfMedia(forIdentifier identifier : String, withNewTags tags : String) {
        
        let data : [String : Any] = [mediaKeys.tags.rawValue : tags]
        
        CloudKitManager.updateRecord(identifier, keysAndValuesToUpdate: data) { (updatedRecord, error) in
            print(updatedRecord!.value(forKey: mediaKeys.tags.rawValue))
        }
    }
    
    
    static func fetchAllMediaFromIClould(_ completion : @escaping([iClouldMediaModel]?) -> Void) {
        
        CloudKitManager.fetchData(ofType: .media) { (records, error) in
            
            if error == nil {
                var arrData = [iClouldMediaModel]()
                
                for record in records ?? [] {
                    arrData.append(iClouldMediaModel.init(image: record.value(forKey: mediaKeys.picture.rawValue) as! Data,
                                                          imageName: record.value(forKey: mediaKeys.pictureName.rawValue) as! String,
                                                          identifier: record.recordID.recordName,
                                                          tags : record.value(forKey: mediaKeys.tags.rawValue) as! String))
                }
                
                completion(arrData)
                
            } else {
                completion(nil)
            }
        }
        
    }
    
//    func fetchAllNotUploadedPhotos() -> {
//
//        for obj in PR_RealmManager.Fetch(realmArray: ModelMedia.self)
//        {
//            // Decryption
//            do {
//
//                let passwordForMedia : String = obj.password
//
//                let originalData = try RNCryptor.decrypt(data: obj.encryptedNameOfItem, withPassword: passwordForMedia)
//
//                let nameFromData = String.init(data: originalData, encoding: String.Encoding.utf8)!
//
//                if obj.isVideo == false {
//
//                    if obj.isUploaded == false {
//
//                    }
//                }
//
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
}
