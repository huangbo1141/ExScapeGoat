//
//  photosManager.swift
//  MediaHider
//
//  Created by user on 27/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit
import Photos

struct photosManager {
    
    //************************************************
    // MARK: Variables
    //************************************************
    
    static var assetCollection: PHAssetCollection!
    static var albumName = "Media Hider"
    
    static let manager = FileManager.default
    
    enum sourceType {
        case photos
        case videos
    }
    static var enumSourceType : sourceType = .photos
    
    static let defaultDocumentPath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    // This is folder name of local path
    static private var photosFolderName = "CustomPhotos"
    static private var videosFolderName = "CustomVideos"
    
    
    //************************************************
    // MARK: Funtions
    //************************************************
    
    
    static func getPathFor(sourceType : sourceType) -> URL
    {
        let directoryName : String = sourceType == .photos ? photosFolderName : videosFolderName
        
        return URL(fileURLWithPath: defaultDocumentPath).appendingPathComponent(directoryName)
    }
    
    
    /**
     Create Folder if needed
     */
    static private func createFolderIfNeeded() {
        
        let path = getPathFor(sourceType: enumSourceType).path
        
        if !isFolderExistAtPath(path: path) {
            do
            {
                try FileManager.default.createDirectory(atPath: path , withIntermediateDirectories: true, attributes: nil)
                
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
    }
    
    
    //    /**
    //     Check Files and Folder exists on that path or not.
    //     */
    
    static func isFolderExistAtPath(path : String) -> Bool {
        var isDir : ObjCBool = false
        if manager.fileExists(atPath: path , isDirectory: &isDir)
        {
            return isDir.boolValue
        }
        
        return false
    }
    
    
    
    /**
     Remove Files And Folder
     */
    static func RemoveItem(atPath path : URL) {
        do
        {
            try FileManager.default.removeItem(at: path) //removeItem(atPath: "here is your file path")
        }
        catch (let error)
        {
            print("Error in removing file of path - \(path) :- " , error.localizedDescription)
        }
    }
    
}



//************************************************
// MARK: Write files to paths here
//************************************************

extension photosManager
{
    static func writeItem(fromData data : Data, withName itemNameWithExt : String) -> String?
    {
        createFolderIfNeeded()
        
        let filePath = getPathFor(sourceType: enumSourceType).appendingPathComponent(itemNameWithExt)
        
        do{
            try data.write(to: filePath)
            
            return itemNameWithExt
            
        }catch(let error){
            print("Error in Writing item with name = \(itemNameWithExt)" , error.localizedDescription)
            
            return nil
        }
    }
}



//************************************************
// MARK: Fetching files funtions
//************************************************

extension photosManager
{
    /// Setup album here. If exist then getting it otherwise adding it first.
    static func setupAlbum()
    {
        if self.assetCollection == nil {
            
            func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
                let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                
                if let firstObject = collection.firstObject {
                    return firstObject
                }
                
                return nil
            }
            
            if let assetCollection = fetchAssetCollectionForAlbum() {
                self.assetCollection = assetCollection
            }
            else
            {
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                }) { success, _ in
                    if success {
                        self.assetCollection = fetchAssetCollectionForAlbum()
                    }
                }
            }
        }
    }
    
    /// In this just pass the source type and media name and get the url and data of that media.
    static func fetchItem(ofType type : sourceType, withName name : String) -> (Data,URL)?
    {
        let MainPath = self.getPathFor(sourceType: type)
        
        let ItemPath = MainPath.appendingPathComponent(name)
        
        do {
            
            let data = try Data.init(contentsOf: ItemPath)
            
            return (data, ItemPath)
            
        } catch  {
            return nil
        }
    }
    
    /// This will help to save image to path
    static func saveImage(image: UIImage ,handler : @escaping(String?) -> ()) {
        
        self.setupAlbum()
        
        var photoAssetPlaceholder : PHObjectPlaceholder! // Placeholder url
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            photoAssetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [photoAssetPlaceholder!]
            albumChangeRequest!.addAssets(enumeration)
            
        }, completionHandler:{ (b , e) in
            
            if b
            {
                /// Currently we don't need this.
                
//                let localID = photoAssetPlaceholder.localIdentifier
//
//                let assestsId = localID.replacingOccurrences(of: "/.*", with: "")
//                let ext = imageFormat
//                let assetURLStr = "assets-library://asset/asset.\(ext)?id=\(assestsId)&ext=\(ext)"
                
                handler("")
            }
            else
            {
                handler(nil)
            }
        })
    }
    
    /// This will help to save video to path
    static func saveVideo(urlPath : URL , handler : @escaping(String?) -> ())  {
        
        self.setupAlbum()
        
        let photoLibrary = PHPhotoLibrary.shared()
        
        PHPhotoLibrary.requestAuthorization({ (status) in
            
            if status == PHAuthorizationStatus.authorized
            {
                var videoAssetPlaceholder : PHObjectPlaceholder!
                
                photoLibrary.performChanges({
                    
                    let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: urlPath)
                    videoAssetPlaceholder = request!.placeholderForCreatedAsset
                    
                }, completionHandler: { (b, e) in
                    
                    if b
                    {
                        let localID = videoAssetPlaceholder.localIdentifier
                        
                        let assestsId = localID.replacingOccurrences(of: "/.*", with: "")
                        let ext = "mp4"
                        let assetURLStr = "assets-library://asset/asset.\(ext)?id=\(assestsId)&ext=\(ext)"
                        
                        DispatchQueue.main.async {
                            handler(assetURLStr)
                        }
                    }
                    else
                    {
                        handler(nil)
                    }
                })
            }
        })
    }
}

