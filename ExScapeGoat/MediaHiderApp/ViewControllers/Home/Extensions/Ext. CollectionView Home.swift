//
//  Ext. Table Home.swift
//  MediaHider
//
//  Created by user on 24/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit
import PR_utilss


extension home : UICollectionViewDataSource , UICollectionViewDelegate
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if enumSourceType == .photos
        {
            return arrPhotos.count
        }
        else if enumSourceType == .videos
        {
            return arrVideos.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cln.dequeueReusableCell(withReuseIdentifier: "cellClnVcHome", for: indexPath) as! cellClnVcHome
        
        var obj : ModelMediaHome!
        
        if enumSourceType == .photos
        {
            obj = arrPhotos[indexPath.row]
            
            cell.imageVPLay.isHidden = true
        }
        else if enumSourceType == .videos
        {
            obj = arrVideos[indexPath.row]
            
            cell.imageVPLay.isHidden = false
        }
        
        if obj.isSelected
        {
            cell.imageVTick.isHidden = false
        }
        else
        {
            cell.imageVTick.isHidden = true
        }
        
        cell.imageV.image = obj.previewImage
        
        let guesture = CustomUILongPressGestureRecognizer(target: self, action: #selector(longGuesturePressed(_:)))        
        guesture.indexPath = indexPath
        cell.addGestureRecognizer(guesture)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isSelectingEnable
        {
            if enumSourceType == .photos
            {
                arrPhotos[indexPath.row].isSelected = !arrPhotos[indexPath.row].isSelected
            }
            else if enumSourceType == .videos
            {
                arrVideos[indexPath.row].isSelected = !arrVideos[indexPath.row].isSelected
            }
            
            self.cln.reloadItems(at: [indexPath])
            
            self.adjustNavigationAsPerSelection()
        }
        else
        {
            if enumSourceType == .photos
            {
                if let vc = G_getVc(ofType: ShowImage(), FromStoryBoard: storyBoards.main, withIdentifier: vcIdentifiers.ShowImage)
                {
                    vc.img = arrPhotos[indexPath.row].img
                    vc.title = arrPhotos[indexPath.row].itemName
                    (UIApplication.shared.keyWindow?.rootViewController as! UINavigationController).pushViewController(vc, animated: true)
                }
            }
            else if enumSourceType == .videos
            {
                self.playVideo(self.arrVideos[indexPath.row].imagePath)
            }
            
        }
    }
}

extension home : UICollectionViewDelegateFlowLayout
{
    private static let margin = UIScreen.main.bounds.size.width * 0.05
    
    static let w = UIScreen.main.bounds.size.width * 0.45 + margin/3.5
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let h = UIScreen.main.bounds.size.width * 0.45 + home.margin/3.5 // UIScreen.main.bounds.size.height * 0.35
        
        return CGSize(width: home.w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        
        let m = home.margin/2
        
        return UIEdgeInsetsMake(m, m, m, m)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        
        return home.margin/2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        
        return 0
    }
}


class cellClnVcHome: UICollectionViewCell {
    
    @IBOutlet weak var imageV : customUIImageView!
    @IBOutlet weak var imageVTick : customUIImageView!
    @IBOutlet weak var imageVPLay : customUIImageView!
    
}
