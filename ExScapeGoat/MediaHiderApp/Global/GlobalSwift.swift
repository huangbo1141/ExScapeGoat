//
//  Globals.swift
//  MediaHider
//
//  Created by q on 1/15/18.
//  Copyright © 2018 user. All rights reserved.
//

import Foundation
import Photos
import AVFoundation


private let _sharedManager = GlobalSwift()

class GlobalSwift:NSObject{
    class var sharedManager:GlobalSwift {
        return _sharedManager;
    }
    public required override init(){
        
    }
    
    
    static func checkPhotoLibraryPermission(completion:@escaping (_ result:Bool)->()){
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
            return
        case .denied,.restricted:
            completion(false)
            return
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized:
                    completion(true)
                case .denied,.restricted:
                    completion(false)
                case .notDetermined:
                    return
                default:
                    return
                }
            })
        default:
            return
        }
        
    }
    
    static func checkAVCapturePermission(completion:@escaping (_ result:Bool)->()){
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
            return
        case .denied,.restricted:
            completion(false)
            return
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (status) in
                completion(status)
            })
            
        default:
            return
        }
        
    }
    
    static func checkMicroPhonePermission(completion:@escaping (_ result:Bool)->()){
        let status = AVAudioSession.sharedInstance().recordPermission()
        switch status {
        case .granted:
            completion(true)
            return
        case .denied:
            completion(false)
            return
        case .undetermined:
            
            AVAudioSession.sharedInstance().requestRecordPermission({ (status) in
                completion(status)
            })
            
        default:
            return
        }
        
    }
    
}
