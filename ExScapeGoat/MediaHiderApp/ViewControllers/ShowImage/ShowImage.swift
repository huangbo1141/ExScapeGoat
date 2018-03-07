//
//  ShowImage.swift
//  MediaHider
//
//  Created by user on 29/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

class ShowImage: baseVc {
    
    //*********************************************
    // MARK: Variables
    //*********************************************
    
    /// Helper
    
    let strAddTag = "Add Tag"
    
    /// Other
    
    var img : UIImage? = nil // Getted
    
    var realmModel : ModelMedia! // Getted
    
    var arrTags : [String] {
        var tmp : [String] = realmModel.tags.components(separatedBy: ",")
        tmp.append(strAddTag)
        return tmp
    }    
    
    //*********************************************
    // MARK: Outlets
    //*********************************************
    
    @IBOutlet weak var imageV : customUIImageView!
    
    @IBOutlet weak var clnTags : UICollectionView!
    
    //*********************************************
    // MARK: Defaults
    //*********************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let img = self.img {
            self.imageV.image = img
        }
                
        (clnTags.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = .zero
        (clnTags.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = 5
        (clnTags.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//*********************************************
// MARK: Actions
//*********************************************

extension ShowImage
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

extension ShowImage
{
    
}
