//
//  Ext. Restoration Works.swift
//  MediaHider
//
//  Created by user on 30/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit

extension home
{
    func clickOnRestoreButton()  {
        
        var arrSelectedObj : [ModelMediaHome]!
        
        if enumSourceType == .photos
        {
            arrSelectedObj = self.arrPhotos.filter{ return $0.isSelected == true }
        }
        else if enumSourceType == .videos
        {
            arrSelectedObj = self.arrVideos.filter{return $0.isSelected == true}
        }
        
        self.deleteSelectedMediaAndSaveToLibrary(arrObj: arrSelectedObj)
    }
    
    func deleteSelectedMediaAndSaveToLibrary(arrObj : [ModelMediaHome])  {
        
        G_loaderShow()
        
        var arrDynamicObj = arrObj
        
        var count = 0
        
        func saveAndDelete()
        {
            if arrDynamicObj.indices.contains(count)
            {
                let obj = arrDynamicObj[count]
                
                if enumSourceType == .photos
                {
                    
                    photosManager.saveImage(image: obj.img, handler: { strUrl in
                        
                        if let _ = strUrl
                        {
                            DispatchQueue.main.async {
                                
                                /// Remove From Realm
                                if let objRealm = PR_RealmManager.Fetch(realmSingleObject: ModelMedia.self, withPrimaryKey: obj.objPrimaryKey)
                                {
                                    PR_RealmManager.Delete(object: objRealm)
                                }
                                
                                /// Delete From Path
                                photosManager.RemoveItem(atPath: obj.imagePath)
                                
                                /// Remove from Array
                                arrDynamicObj.remove(at: count)
                                
                                saveAndDelete()
                            }
                        }
                        else
                        {
                            arrDynamicObj.remove(at: count)
                            saveAndDelete()
                        }
                    })
                }
                else if enumSourceType == .videos
                {
                    photosManager.saveVideo(urlPath: obj.imagePath, handler: { strUrl in
                        
                        if let _ = strUrl
                        {
                            DispatchQueue.main.async {
                                
                                /// Remove From Realm
                                if let objRealm = PR_RealmManager.Fetch(realmSingleObject: ModelMedia.self, withPrimaryKey: obj.objPrimaryKey)
                                {
                                    PR_RealmManager.Delete(object: objRealm)
                                }
                                
                                /// Delete From Path
                                photosManager.RemoveItem(atPath: obj.imagePath)
                                
                                /// Remove from Array
                                arrDynamicObj.remove(at: count)
                                
                                saveAndDelete()
                            }
                        }
                        else
                        {
                            arrDynamicObj.remove(at: count)
                            saveAndDelete()
                        }
                    })
                }
            }
            else
            {
                G_loaderHide()
                
                self.setupData()
                self.adjustNavigationAsPerSelection()
            }
        }
        
        saveAndDelete()
    }
}
