//
//  Ext. Tag ClnV _ShowImage.swift
//  ExScapeGoat
//
//  Created by user on 04/03/18.
//  Copyright © 2018 iWazowski.com. All rights reserved.
//

import Foundation
import UIKit

extension ShowImage : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : UICollectionViewCell = clnTags.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if let lbl = cell.contentView.viewWithTag(99) as? UILabel {
            lbl.layer.cornerRadius = 3
            lbl.layer.masksToBounds = true
            lbl.adjustsFontSizeToFitWidth = true
            lbl.backgroundColor = G_colorBlueLight
            lbl.text = arrTags[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if arrTags[indexPath.row] == strAddTag {
            AddTagsPopup.showOn(viewController: self, Handler: { (tag) in
                
                G_realm.beginWrite()
                
                self.realmModel.tags.append(tag + ",")
                
                try? G_realm.commitWrite()
                
                self.clnTags.reloadData()
                
                /// sync with iclould
                if self.realmModel.isUploaded {
                    clouldKitHelper.updateTagsOfMedia(forIdentifier: self.realmModel.iclouldIdentifier, withNewTags: self.realmModel.tags)
                }
            })
        }
    }
}

extension ShowImage : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
      return arrTags[indexPath.row].sizeOfString(usingFont: UIFont.boldSystemFont(ofSize: 16))
    }
}





