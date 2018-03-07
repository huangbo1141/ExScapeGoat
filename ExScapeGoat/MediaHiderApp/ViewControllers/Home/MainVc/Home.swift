//
//  Home.swift
//  MediaHider
//
//  Created by user on 24/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RealmSwift
import Photos

class home: baseVc {
    
    //*********************************************
    // MARK: Variables
    //*********************************************
    
    /**
     Helpers
     */
    var isFirstOpen : Bool {
        get{ return !UserDefaults.standard.bool(forKey: "isFirstOpen")}
        set(newValue){ UserDefaults.standard.set(newValue, forKey: "isFirstOpen")}
    }
    
    /// This will help in selecting media
    var isSelectingEnable = false
    
    /// Search Helper
    var isSearching = false
    
    /**
     UI Related
     */
    
    var searchBar: UISearchBar?
    
    /**
     Datasourcce
     */
    enum sourceType {
        case photos
        case videos
        case none
    }
    var enumSourceType : sourceType = .none
    
    var tabBase : TabBaseViewController? = nil
    
    struct ModelMediaHome {
        var previewImage : UIImage!
        var img : UIImage!
        var imagePath : URL!
        var isSelected : Bool!
        var itemName : String!
        var objPrimaryKey : String!
        var realmModel : ModelMedia!
    }
    var arrPhotos = [ModelMediaHome]()
    var arrFilteredPhotos = [ModelMediaHome]()
    var arrVideos = [ModelMediaHome]()
    
    //*********************************************
    // MARK: Outlets
    //*********************************************
    
    @IBOutlet weak var cln : UICollectionView!
    
    //*********************************************
    // MARK: Defaults
    //*********************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFirstOpen {
            self.checkAndAskToRestoreFromClould()
        } else {

            G_loaderShow()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                /// Setup Data
                self.setupData()
            })
        }
        
//        clouldKitHelper.syncPhotosWithiClould()
//
//        CloudKitManager.fetchData(ofType: .media, { (records, error) in
//
//            print("This is sample", records?.count)
//
//            records!.forEach({
//
//                CloudKitManager.removeRecord($0.recordID.recordName, completion: { (record, error) in
//                    print(record, "is Deleted")
//                })
//            })
//        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// Setting custom deligate.
        for vcs in UIApplication.shared.keyWindow!.rootViewController!.childViewControllers
        {
            if let tabBase = vcs as? TabBaseViewController
            {
                tabBase.deligateCustom = nil
                tabBase.deligateCustom = self;
                
                break;
            }
        }
        
        // Deselect All And Adjust UI
        self.deselectAllAndAdjustUI(for: enumSourceType)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("Memory Warning Recieved")
        
    }
    
    /// BaseViewController Defaults
    
    func baseTabViewWillDisappear() {
       self.searchBar?.removeFromSuperview()
    }
}


//*********************************************
// MARK: Actions
//*********************************************

extension home
{
    /**
     #selectors
     */
    
    
    /**
     @IBActions
     */
}


//*********************************************
// MARK: Custom Methods
//*********************************************

extension home
{
    /**
     Setup Data
     - Decrypt Path by password and populate media array's
     */
    func setupData()  {
        
        self.arrPhotos.removeAll()
        self.arrVideos.removeAll()
        
        let group = DispatchGroup()
        
        G_threadMain {
            
            for obj in PR_RealmManager.Fetch(realmArray: ModelMedia.self)
            {
                // Decryption
                do {
                    
                    let passwordForMedia : String = obj.password
                    
                    let originalData = try RNCryptor.decrypt(data: obj.encryptedNameOfItem, withPassword: passwordForMedia)
                    
                    let nameFromData = String.init(data: originalData, encoding: String.Encoding.utf8)!
                    
                    if obj.isVideo == false && self.enumSourceType == .photos {
                        
                        group.enter()
                        G_threadBackground {
                            
                            if let dataAndURL = photosManager.fetchItem(ofType: .photos, withName: nameFromData)
                            {
                                let orignalImage = UIImage.init(data: dataAndURL.0)
                                
                                let previewImage = self.resizeImage(image: orignalImage!)
                                
                                self.arrPhotos.append(home.ModelMediaHome.init(previewImage: previewImage,
                                                                               img: orignalImage!,
                                                                               imagePath: dataAndURL.1,
                                                                               isSelected: false,
                                                                               itemName : nameFromData,
                                                                               objPrimaryKey : passwordForMedia,
                                                                               realmModel : obj))
                            }
                            
                            group.leave()
                        }
                    } else if obj.isVideo == true && self.enumSourceType == .videos {
                        
                        group.enter()
                        G_threadBackground {
                            
                            if let dataAndURL = photosManager.fetchItem(ofType: .videos, withName: nameFromData)
                            {
                                let thumNailImage = self.getThumbnailFrom(path: dataAndURL.1)
                                let previewImage = self.resizeImage(image: thumNailImage!)
                                
                                self.arrVideos.append(home.ModelMediaHome.init(previewImage: previewImage,
                                                                               img: nil,
                                                                               imagePath: dataAndURL.1,
                                                                               isSelected: false,
                                                                               itemName : nameFromData,
                                                                               objPrimaryKey : passwordForMedia,
                                                                               realmModel : obj))
                            }
                            
                            group.leave()
                        }
                    }
                    
                } catch {
                    print(error)
                }
            }
        }
        
        group.notify(queue: .main) {
            
            self.cln.reloadData()
            
            G_loaderHide()
            
            self.adjustNavigationAsPerSelection()
        }
    }
    
    /**
     Selectors
     */
    
    /// Single Selection Work here.
    @objc func longGuesturePressed(_ sender : CustomUILongPressGestureRecognizer)  {
        
        /// No need this if user is searching pictures
        if isSearching {
            return
        }
        
        if sender.state == .began
        {
            self.isSelectingEnable = true
            
            guard let indexPath = sender.indexPath else { return }
            
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
    }
}


//*********************************************
// MARK: Custom Deligate Functions
//*********************************************

extension home
{
    /**
     Funtions executed from TabBaseVc
     */
    
    public func clickedOnAddButton() {
        
        /// Needed at multiple places
        func refreshData() {
            G_loaderHide()
            self.setupData()
            
            /// Sync with iClould
            clouldKitHelper.syncPhotosWithiClould()
        }
        
        let pickerController = DKImagePickerController()
        pickerController.assetType = enumSourceType == .photos ? .allPhotos : .allVideos
        pickerController.sourceType = .photo
        
        pickerController.didSelectAssets = { (assets : [DKAsset]) in
            
            PHPhotoLibrary.shared().performChanges({
                
                let enumeration: NSArray = assets.map{$0.originalAsset!} as NSArray //[assets.last!.originalAsset!]
                
                PHAssetChangeRequest.deleteAssets(enumeration)
                
            }, completionHandler: {success, error in
                
                if assets.isEmpty { return }
                
                G_loaderShow()
                
                let groupPhotos = DispatchGroup()
                let groupVideos = DispatchGroup()
                
                func SaveMediaToLocal(count : Int)  {
                    
                    let asset = assets[count]
                    
                    if self.enumSourceType == .photos
                    {
                        asset.fetchOriginalImage(false, completeBlock: { (img, info) in
                            
                            if let data =  UIImageJPEGRepresentation(img!, 0.25)
                            {
                                var imgName = ""
                                
                                if let imageURL = info!["PHImageFileURLKey"] as? URL
                                {
                                    imgName = imageURL.lastPathComponent
                                }
                                
                                photosManager.enumSourceType = .photos
                                
                                if let itemName = photosManager.writeItem(fromData: data, withName: imgName)
                                {
                                    if let itemNameData: Data = itemName.data(using: .utf8)
                                    {
                                        groupPhotos.enter()
                                        DispatchQueue.main.async {
                                            
                                            let pass = "\(arc4random_uniform(999999999))"
                                            
                                            let data = RNCryptor.encrypt(data: itemNameData, withPassword: pass)
                                            
                                            let obj = ModelMedia()
                                            
                                            obj.encryptedNameOfItem = data
                                            obj.password = pass
                                            
                                            PR_RealmManager.Add(objectToRealm: obj, update: false, errorMessage: "Inn")
                                            
                                            groupPhotos.leave()
                                        }
                                    }
                                }
                            }
                            
                            groupPhotos.notify(queue: .main, execute: {
                              
                                if assets.count == count + 1
                                {
                                    refreshData()
                                }
                                else
                                {
                                    SaveMediaToLocal(count: count + 1)
                                }
                            })
                        })
                    }
                    else if self.enumSourceType == .videos
                    {
                        asset.fetchAVAssetWithCompleteBlock({ (avAsset, dic) in
                            
                            if let avUrlAsset = avAsset as? AVURLAsset
                            {
                                do
                                {
                                    let url = avUrlAsset.url
                                    
                                    let videoData = try Data.init(contentsOf: url)
                                    let videoName = url.lastPathComponent
                                    
                                    photosManager.enumSourceType = .videos
                                    
                                    if let itemName = photosManager.writeItem(fromData: videoData, withName: videoName)
                                    {
                                        if let itemNameData: Data = itemName.data(using: .utf8)
                                        {
                                            groupVideos.enter()
                                            DispatchQueue.main.async {
                                                
                                                let pass = "Video\(arc4random_uniform(999999999))"
                                                
                                                let data = RNCryptor.encrypt(data: itemNameData, withPassword: pass)
                                                
                                                let obj = ModelMedia()
                                                
                                                obj.encryptedNameOfItem = data
                                                obj.password = pass
                                                obj.isVideo = true
                                                
                                                PR_RealmManager.Add(objectToRealm: obj, update: false, errorMessage: "Inn")
                                            
                                                groupVideos.leave()
                                            }
                                        }
                                    }
                                }
                                catch
                                {
                                    
                                }
                            }
                           
                            groupVideos.notify(queue: .main, execute: {
                              
                                if assets.count == count + 1
                                {
                                    refreshData()
                                }
                                else
                                {
                                    SaveMediaToLocal(count: count + 1)
                                }
                            })
                        })
                    }
                    
                }
                
                SaveMediaToLocal(count: 0)
            })
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    enum conditionType {
        case selectBack
        case selectAll        
        case selectNone
    }
    func clickOnDropDownButton(condition : conditionType) {
        
        if condition == .selectAll
        {
            if enumSourceType == .photos
            {
                for i in 0..<arrPhotos.count
                {
                    arrPhotos[i].isSelected = true
                }
            }
            else if enumSourceType == .videos
            {
                for i in 0..<arrVideos.count
                {
                    arrVideos[i].isSelected = true
                }
            }
        }
        else if condition == .selectNone
        {
            if enumSourceType == .photos
            {
                for i in 0..<arrPhotos.count
                {
                    arrPhotos[i].isSelected = false
                }
            }
            else if enumSourceType == .videos
            {
                for i in 0..<arrVideos.count
                {
                    arrVideos[i].isSelected = false
                }
            }
        }
        else if condition == .selectBack
        {
            self.navigationController?.popViewController(animated: true)
            return;
        }
        
        self.cln.reloadData()
        
        self.adjustNavigationAsPerSelection()
    }    
}


//***************************************************************
// MARK: Helpers
//***************************************************************

import AVKit

extension home
{
    /// Get Thumbnail from Video
    
    func getThumbnailFrom(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            
        } catch let error {
            
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
            
        }
    }
    
    
    /// Play Video By URL
    
    func playVideo(_ url: URL) {
        let avPlayerItem = AVPlayerItem.init(url: url)
        
        let avPlayer = AVPlayer(playerItem: avPlayerItem)
        let player = AVPlayerViewController()
        player.player = avPlayer
        
        avPlayer.play()
        
        self.present(player, animated: true, completion: nil)
    }
    
    
    /// Collection View :- Deselect All Cells and Adjust Navigation bar
    
    func deselectAllAndAdjustUI(for sourceType  : sourceType)  {
        if sourceType == .photos
        {
            for i in 0..<self.arrPhotos.count
            {
                self.arrPhotos[i].isSelected = false
            }
        }
        else if sourceType == .videos
        {
            for i in 0..<self.arrVideos.count
            {
                self.arrVideos[i].isSelected = false
            }
        }
        
        self.adjustNavigationAsPerSelection()
        
        self.cln.reloadData()
    }
    
    
    // Adjust Navigation bars as per selection
    
    func adjustNavigationAsPerSelection() {
        
        var arrItems : [ModelMediaHome]!
        
        if enumSourceType == .photos
        {
            arrItems = arrPhotos
        }
        else if enumSourceType == .videos
        {
            arrItems = arrVideos
        }
        
        var isAnyPhotosSelected = false
        
        for i in arrItems
        {
            if i.isSelected
            {
                isAnyPhotosSelected = true
                break
            }
        }
        
        if isAnyPhotosSelected
        {
            isSelectingEnable = true
            tabBase?.showRestoreNavigationButton()
        }
        else
        {
            isSelectingEnable = false
            
            if enumSourceType == .photos {
                tabBase?.showAdd_SearchNavigationButton()
            } else if enumSourceType == .videos {
                tabBase?.showAddNavigationButton()
            }
        }
    }
    
    
    // Compress Image and resize
    
    //image compression
    func resizeImage(image: UIImage) -> UIImage {
        var actualHeight: CGFloat = image.size.height
        var actualWidth: CGFloat = image.size.width
        let maxHeight: CGFloat = home.w
        let maxWidth: CGFloat = home.w
        var imgRatio: CGFloat = actualWidth / actualHeight
        let maxRatio: CGFloat = maxWidth / maxHeight
        let compressionQuality: CGFloat = 0.5
        //50 percent compression
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRect(x: 0, y: 0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img!,CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!)!
    }
}


extension home {
    
    func checkAndAskToRestoreFromClould() {
        
        clouldKitHelper.fetchAllMediaFromIClould { (arrDataOptional) in
            
            if let arrData = arrDataOptional, arrData.isEmpty == false {
                
                let alert = UIAlertController.init(title: "Restore", message: "Restore previous data from iCLould", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .destructive, handler: { (_) in
                    self.isFirstOpen = true
                }))
                
                alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { (_) in
                    self.isFirstOpen = true
                    self.fetchFromiClould()
                }))
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else {
                self.setupData()
            }
        }
    }
    
    func fetchFromiClould() {
        
        G_loaderShow()
        
        let iclouldRestoreGroup = DispatchGroup()
        
        clouldKitHelper.fetchAllMediaFromIClould { (arrDataOptional) in
            
            if let arrData = arrDataOptional {
                
                func SaveMediaToLocal(count : Int)  {
                    
                    let data : Data =  arrData[count].image!
                    
                    var imgName : String = arrData[count].imageName!
                    
                    photosManager.enumSourceType = .photos
                    
                    if let itemName = photosManager.writeItem(fromData: data, withName: imgName)
                    {
                        if let itemNameData: Data = itemName.data(using: .utf8)
                        {
                            iclouldRestoreGroup.enter()
                            DispatchQueue.main.async {
                                
                                let pass = "\(arc4random_uniform(999999999))"
                                
                                let data = RNCryptor.encrypt(data: itemNameData, withPassword: pass)
                                
                                let obj = ModelMedia()
                                
                                obj.encryptedNameOfItem = data
                                obj.password = pass
                                obj.isUploaded = true
                                obj.iclouldIdentifier = arrData[count].identifier
                                obj.tags = arrData[count].tags
                                
                                PR_RealmManager.Add(objectToRealm: obj, update: false, errorMessage: "Inn")
                                
                                iclouldRestoreGroup.leave()
                            }
                        }
                    }
                    
                    iclouldRestoreGroup.notify(queue: .main, execute: {
                        
                        if arrData.count == count + 1
                        {
                            G_loaderHide()
                            self.setupData()
                        }
                        else
                        {
                            SaveMediaToLocal(count: count + 1)
                        }
                    })
                    
                }
                
                SaveMediaToLocal(count: 0)
                
            } else {
                G_loaderHide()
            }
        }
    }
}


