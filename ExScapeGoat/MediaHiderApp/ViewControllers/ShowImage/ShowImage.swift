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
    
    var img : UIImage? = nil // Getted
    
    //*********************************************
    // MARK: Outlets
    //*********************************************
    
    @IBOutlet weak var imageV : customUIImageView!
    
    //*********************************************
    // MARK: Defaults
    //*********************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let img = self.img
        {
            self.imageV.image = img
        }
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
