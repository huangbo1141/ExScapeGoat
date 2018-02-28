//
//  PR_RealmManager.swift
//  Steath Care Mobile
//
//  Created by User on 15/11/17.
//  Copyright © 2017 Saurabh Sawla. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit


/**
 * Notes :-
 * - To use this funtions make sure array of objects should be declare as List<Object>()
 */

/// Global Shared instance
let G_realm = try! Realm()


/**
 Global RealmList
 - This will help when we have to use list class without importing RealmSwift to destination class.
 */
public typealias PR_Realmlist = List



/// global functions for write transactions
func G_realmBeginWrite()  { if !G_realm.isInWriteTransaction { G_realm.beginWrite() } }
func G_realmCommitWrite(errorIn str : String = "") { if G_realm.isInWriteTransaction { do {  try G_realm.commitWrite() } catch { print("Error in \(str)" ,error) } } }



class PR_RealmManager {
    
    /**
     Fetch list of objects from Realm Database.
     */
    static func Fetch<T>(realmArray ofType : T.Type) -> Results<T> where T : Object {
        return G_realm.objects(ofType);
    }
    
    /**
     Fetch single object from Realm Database with primary key.
     */
    static func Fetch<T>(realmSingleObject ofType : T.Type, withPrimaryKey primaryKey : String ) -> T? where T : Object {
        return G_realm.object(ofType: ofType, forPrimaryKey: primaryKey)
    }
    
    /**
     Adding object to Realm Database
     */
    static func Add(objectToRealm object : Object , update : Bool = false, errorMessage : String = "")  {
        
        G_realmBeginWrite()
        
        G_realm.add(object, update: update)
        
        G_realmCommitWrite(errorIn: errorMessage.PR_isEmpty ? "Adding Object to local" : errorMessage)
    }
    
    /**
     Deleting single object to Realm Database
     */
    static func Delete(objectFromRealm object : Object, errorMessage : String = "")  {
        
        G_realmBeginWrite()
        
        G_realm.delete(object)
        
        G_realmCommitWrite(errorIn: errorMessage.PR_isEmpty ? "Deleting Object from local" : errorMessage)
    }
    
    /**
     Deleting all objects from Realm Models
     */
    static func Delete(objectsFromModel ofType : Object.Type, errorMessage : String = "")  {
        
        G_realmBeginWrite()
        
        for i in Fetch(realmArray: ofType)
        {
            G_realm.delete(i)
        }
        
        G_realmCommitWrite(errorIn: errorMessage.PR_isEmpty ? "Deleting Objects from given model" : errorMessage)
    }
    
    
    //**********************************
    // MARK: List funtions
    //**********************************
    
    /**
     Adding items to a list
     */
    static func Add<T>(itemsTo Lists : List<T> , withObject type : T.Type , fromArrayof Objects : [T] , update : Bool) where T : Object  {
        
        G_realmBeginWrite()
        
        for object in Objects
        {
            let updatableObj = G_realm.create(type, value: object, update: update)
            
            Lists.append(updatableObj)
        }
        
        G_realmCommitWrite(errorIn: "Adding items in \(type)")
    }
    
    /**
     Delete mutiple items
     */
    static func Delete<T>(allItemsOf Lists : List<T>) where T : Object {
        
        G_realmBeginWrite()
        
        Lists.removeAll()
        
        G_realmCommitWrite(errorIn: "Deleting items")
    }
    
    /**
     Delete single item
     */
    static func Delete<T>(object : T) where T : Object {
        
        G_realmBeginWrite()
        
        G_realm.delete(object)
        
        G_realmCommitWrite(errorIn: "Deleting item")
    }
    
    /**
     Updating item of a list
     */
    static func Update<T>(item : T, ofType type : T.Type , toList lists : List<T>, atIndex index : Int , update : Bool) where T : Object {
        
        G_realmBeginWrite()
        
        let updatableObj = G_realm.create(type, value: item, update: update)
        lists[index] = updatableObj
        
        G_realmCommitWrite(errorIn: "Upadting item")
    }
}
