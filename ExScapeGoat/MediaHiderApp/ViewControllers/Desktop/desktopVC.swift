//
//  desktopVC.swift
//  MediaHider
//
//  Created by q on 1/13/18.
//  Copyright © 2018 user. All rights reserved.
//

import UIKit
import MobileCoreServices
import AssetsLibrary
import Photos


class desktopVC: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,QMChatServiceDelegate,QMChatConnectionDelegate {

    @IBOutlet var constraint_StatusBar: NSLayoutConstraint!
    @IBOutlet var viewIconHolder: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.shared.delegate as! QMAppDelegate
        delegate.currentDesktop = 1
        
        self.constraint_StatusBar.constant = -1 * UIApplication.shared.statusBarFrame.height
        // Do any additional setup after loading the view.
        if let userData = QMCore.instance().currentProfile.userData{
//            CGlobal.showIndicator(self)
            QMCore.instance().chatService.addDelegate(self)
            CGlobal.performAutoLoginAndFetchData(self)
        }else{
            // no need to login
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var imgBack: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        if let index = SettingManager.getBackgroundIndex {
            let imageName = "desktopoo" + index + ".jpg"
            if let image = UIImage.init(named: imageName) {
                imgBack.image = image
            }
        }else {
            let imageName = "desktopoo0.jpg"
            if let image = UIImage.init(named: imageName) {
                imgBack.image = image
            }
        }
        
        let delegate = UIApplication.shared.delegate as! QMAppDelegate
        if delegate.curentPassMode == 1 {
            self.viewIconHolder.isHidden = true
        }else{
            self.viewIconHolder.isHidden = false
        }
    }
    
   
    
    @IBAction func clickCamera(_ sender: UIView) {
        // show camera
        let ac = UIAlertController.init()
        let ac1 = UIAlertAction.init(title: "Take Picture", style: .default) { (action) in
            //hgc
            let globalswift = GlobalSwift.sharedManager
            GlobalSwift.checkAVCapturePermission(completion: { (ret) in
                if ret {
                    self.takePhoto(sender: nil)
                }
            })
            
            
        }
        let ac2 = UIAlertAction.init(title: "Take Video", style: .default) { (action) in
            let globalswift = GlobalSwift.sharedManager
            GlobalSwift.checkAVCapturePermission(completion: { (ret) in
                if ret {
                    self.takeVideo(sender: nil)
                }
            })
        }
        ac.addAction(ac1)
        ac.addAction(ac2)
        
        ac.popoverPresentationController?.sourceView = sender
        self.present(ac, animated: true) {
            //
            debugPrint("action")
        }
    }
    var pickerController = UIImagePickerController()
    
    func takePhoto(sender: AnyObject?) {
        let vc = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickerController = UIImagePickerController();
            pickerController.allowsEditing = false;
            pickerController.delegate = self
            pickerController.sourceType = .camera
            pickerController.cameraCaptureMode = .photo
            
            vc.present(pickerController, animated: true, completion: nil)
        }else{
            debugPrint("Camera is not available")
        }
    }
    func takeVideo(sender: AnyObject?) {
        // 1 Check if project runs on a device with camera available
        let vc = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            // 2 Present UIImagePickerController to take video
            pickerController = UIImagePickerController()
            pickerController.sourceType = .camera
            pickerController.mediaTypes = [kUTTypeMovie as! String]
            pickerController.delegate = self
            pickerController.videoMaximumDuration = 10.0
            pickerController.cameraCaptureMode = .video
            
            vc.present(pickerController, animated: true, completion: nil)
        }
        else {
            
            debugPrint("Camera is not available")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // 1
        let mediaType:AnyObject? = info[UIImagePickerControllerMediaType] as AnyObject?
        
        if let type:AnyObject = mediaType {
            if type is String {
                let stringType = type as! String
                if stringType == kUTTypeMovie as String {
                    let urlOfVideo = info[UIImagePickerControllerMediaURL] as? URL
                    if let url = urlOfVideo {
                        do {
                            let videoData = try Data.init(contentsOf: url)
                            let videoName = url.lastPathComponent
                            
                            photosManager.enumSourceType = .videos
                            
                            if let itemName = photosManager.writeItem(fromData: videoData, withName: videoName)
                            {
                                if let itemNameData: Data = itemName.data(using: .utf8)
                                {
                                    G_loaderShow()
                                    DispatchQueue.main.async {
                                        
                                        let pass = "Video\(arc4random_uniform(999999999))"
                                        
                                        let data = RNCryptor.encrypt(data: itemNameData, withPassword: pass)
                                        
                                        let obj = ModelMedia()
                                        
                                        obj.encryptedNameOfItem = data
                                        obj.password = pass
                                        obj.isVideo = true
                                        
                                        PR_RealmManager.Add(objectToRealm: obj, update: false, errorMessage: "Inn")
                                        G_loaderHide()
                                        
                                    }
                                }
                            }
                        }catch{
                            
                        }
                        
                    }
                }else if stringType == kUTTypeImage as String {
                    // CheckInAttrViewController
                    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
                        // image process
                        debugPrint("xxxx")
                        if let data =  UIImageJPEGRepresentation(image, 0.25)
                        {
                            let seconds:Int = Int(Date.init().timeIntervalSince1970)
                            let imgName = String(seconds)
                            
                            photosManager.enumSourceType = .photos
                            
                            if let itemName = photosManager.writeItem(fromData: data, withName: imgName)
                            {
                                if let itemNameData: Data = itemName.data(using: .utf8)
                                {
                                    G_loaderShow()
                                    DispatchQueue.main.async {
                                        
                                        let pass = "\(arc4random_uniform(999999999))"
                                        
                                        let data = RNCryptor.encrypt(data: itemNameData, withPassword: pass)
                                        
                                        let obj = ModelMedia()
                                        
                                        obj.encryptedNameOfItem = data
                                        obj.password = pass
                                        
                                        PR_RealmManager.Add(objectToRealm: obj, update: false, errorMessage: "Inn")
                                        G_loaderHide()
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
        // 3
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            
        })
    }
    
    @IBAction func clickPhotos(_ sender: Any) {
        
        if let vc = G_getVc(ofType: TabBaseViewController(), FromStoryBoard: storyBoards.main , withIdentifier: vcIdentifiers.TabBaseVc)
        {
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func clickNotes(_ sender: Any) {
        if let vc = CGlobal.listViewControllerForAllNotes() {
            self.present(vc, animated: true, completion: nil)
//            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    @IBAction func clickMessages(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! QMAppDelegate
        delegate.curentIcon = 0
        if QMCore.instance().currentProfile.userData == nil {
            
            
            if let vc = G_getVc(ofType: UINavigationController(), FromStoryBoard: storyBoards.auth , withIdentifier: vcIdentifiers.HeyNavAuth)
            {
                let mynav = vc as! MyNavViewController
                mynav.presenter = self
                mynav.mode = "present"
                self.present(vc, animated: true, completion: nil)
            }
        }else{
            // if logined before open message
            // NavChat
            if let vc = G_getVc(ofType: UINavigationController(), FromStoryBoard: storyBoards.mainMessage , withIdentifier: vcIdentifiers.HeyNavChat)
            {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func clickPhone(_ sender: Any) {
        self.clickContacts(sender)
        let delegate = UIApplication.shared.delegate as! QMAppDelegate
        delegate.curentIcon = 2
    }
    @IBAction func clickContacts(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! QMAppDelegate
        delegate.curentIcon = 1
        if QMCore.instance().currentProfile.userData == nil {
            
            if let vc = G_getVc(ofType: UINavigationController(), FromStoryBoard: storyBoards.auth , withIdentifier: vcIdentifiers.HeyNavAuth)
            {
                let mynav = vc as! MyNavViewController
                mynav.presenter = self
                mynav.mode = "present"
                self.present(vc, animated: true, completion: nil)
            }
        }else{
            // if logined before open contact
            // NavContacts
            if let vc = G_getVc(ofType: UINavigationController(), FromStoryBoard: storyBoards.mainMessage , withIdentifier: vcIdentifiers.HeyNavContacts)
            {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func clickSetting(_ sender: Any) {
        // setting action
        if let vc = G_getVc(ofType: UINavigationController(), FromStoryBoard: storyBoards.main , withIdentifier: vcIdentifiers.settingNav)
        {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    
    func chatService(_ chatService: QMChatService, chatDidNotConnectWithError error: Error) {
        CGlobal.stopIndicator(self)
        Banner.customBannerShow(title: "", subtitle: NSLocalizedString("QM_STR_CHAT_FAILED_TO_CONNECT_WITH_ERROR", comment: ""), colorCase: .error)
    }
    func chatServiceChatDidConnect(_ chatService: QMChatService) {
        CGlobal.stopIndicator(self)
        Banner.customBannerShow(title: "", subtitle: NSLocalizedString("QM_STR_CHAT_CONNECTED", comment: ""), colorCase: .success)
    }
    func chatServiceChatDidReconnect(_ chatService: QMChatService) {
        CGlobal.stopIndicator(self)
        Banner.customBannerShow(title: "", subtitle: NSLocalizedString("QM_STR_CHAT_RECONNECTED", comment: ""), colorCase: .info)
    }
    func chatServiceChatDidFail(withStreamError error: Error) {
        CGlobal.stopIndicator(self)
    }
    func chatServiceChatHasStartedConnecting(_ chatService: QMChatService) {
        
    }
    func chatServiceChatDidAccidentallyDisconnect(_ chatService: QMChatService) {
        CGlobal.stopIndicator(self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
