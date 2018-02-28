//
//  helperGlobalSubclass.swift
//  HarvestIT
//
//  Created by Iziss_Technology on 21/08/17.
//  Copyright © 2017 Pankaj Ramchandani & Co. All rights reserved.
//

import Foundation
import UIKit
import PR_utilss

struct helperSubclasses {
    
//    let G_colorGreen = UIColor.PR_hex(netHex: "4EB027")
//    let G_colorDarkGreen = UIColor.PR_hex(netHex: "20757B")
//    let G_colorBlue = UIColor.PR_hex(netHex: "0D5C9F")
//    let G_colorWhite = UIColor.PR_hex(netHex: "F5FAFF")
//    let G_colorDarkGray = UIColor.PR_hex(netHex: "666666")
    
    static func color(rawValue : Int) -> UIColor
    {
//        switch rawValue {
//        case 0:
//            return G_colorGreen
//        case 1:
//            return G_colorDarkGreen
//        case 2:
//            return G_colorBlue
//        case 3:
//            return G_colorWhite
//        case 4:
//            return G_colorDarkGray
//
//        default:
//            break
//        }
        return .clear
    }
    
    static func font(_ F_Letter : String , Size : CGFloat) -> UIFont
    {
        var fontName = ""
        
        switch F_Letter
        {
            case "R":
                fontName = G_fontRegular
            break
            case "T" :
                fontName = G_fontThin
            break
        default:
            break
        }
        
        let font = UIFont(name: fontName, size: helperSubclasses.fontSize(Size))
        
        return font ?? UIFont.systemFont(ofSize: helperSubclasses.fontSize(Size))
    }
    
    static func fontSize(_ currentSize : CGFloat) -> CGFloat
    {
        if PR_Ext.iPhone6or7()
        {
            return currentSize + 1
        }
        
        if PR_Ext.iPhone6or7Plus()
        {
            return currentSize + 2
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            return currentSize + 6
        }
        
        return currentSize
    }
    
}
