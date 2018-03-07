//
//  CloutKitManager.swift
//  testSwift
//
//  Created by user on 06/03/18.
//  Copyright © 2018 user. All rights reserved.
//

import Foundation
import CloudKit

//
//  YALCloudKitManager.swift
//  CloudKit-demo
//
//  Created by Maksim Usenko on 3/25/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//

import UIKit
import CloudKit

/// Main Record Type
enum recordType : String {
    case media = "Media"
    case notes = "Notes"
}

class CloudKitManager {
    
    fileprivate init() {
        ///forbide to create instance of helper class
    }
    
    static var privateCloudDatabase: CKDatabase {
        return CKContainer.default().privateCloudDatabase
    }
    
    static var publicCloudDatabase: CKDatabase {
        return CKContainer.default().publicCloudDatabase
    }
    
    //MARK: Retrieve existing records
    static func fetchData(ofType type : recordType, _ completion: @escaping (_ records: [CKRecord]?, _ error: NSError?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: type.rawValue, predicate: predicate)
        
        privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            completion(records,error as NSError?)
        }
    }
    
    //MARK: add a new record
    static func createRecord(ofMediaType mediaType : recordType,_ recordData: [String: Any], completion: @escaping (_ record: CKRecord?, _ error: NSError?) -> Void) {
        
        let record = CKRecord(recordType: mediaType.rawValue)
        
        for (key, value) in recordData {
            record.setValue(value, forKey: key)
        }
        
        privateCloudDatabase.save(record) { (savedRecord, error) in
            DispatchQueue.main.async {
                completion(savedRecord, error as NSError?)
            }
        }
    }
    
    //MARK: updating the record by recordId
    static func updateRecord(_ recordId: String, keysAndValuesToUpdate : [String : Any], completion: @escaping (CKRecord?, NSError?) -> Void) {
        
        let recordId = CKRecordID(recordName: recordId)
        privateCloudDatabase.fetch(withRecordID: recordId) { updatedRecord, error in
            guard let record = updatedRecord else {
                DispatchQueue.main.async {
                    completion(nil, error as NSError?)
                }
                return
            }
            
            for (key,value) in keysAndValuesToUpdate {
                record.setValue(value, forKey: key)
            }
            
            self.privateCloudDatabase.save(record) { savedRecord, error in
                DispatchQueue.main.async {
                    completion(savedRecord, error as NSError?)
                }
            }
        }
    }
    
    //MARK: remove the record
    static func removeRecord(_ recordId: String, completion: @escaping (String?, NSError?) -> Void) {
        let recordId = CKRecordID(recordName: recordId)
        privateCloudDatabase.delete(withRecordID: recordId, completionHandler: { deletedRecordId, error in
            DispatchQueue.main.async {
                completion (deletedRecordId?.recordName, error as NSError?)
            }
        })
    }
    
    //MARK: check that user is logged
    static func checkLoginStatus(_ handler: @escaping (_ islogged: Bool) -> Void) {
        CKContainer.default().accountStatus{ accountStatus, error in
            if let error = error {
                print(error.localizedDescription)
            }
            switch accountStatus {
            case .available:
                handler(true)
            default:
                handler(false)
            }
        }
    }
}



