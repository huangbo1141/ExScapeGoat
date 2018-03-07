//
//  Ext. Search Work.swift
//  ExScapeGoat
//
//  Created by user on 04/03/18.
//  Copyright © 2018 iWazowski.com. All rights reserved.
//

import Foundation
import UIKit

extension home : UISearchBarDelegate {
    
    /// Access from TabBaseViewController
    func clickedOnSearchButton() {
     
        /// Adding search bar
        let sBar = UISearchBar.init(frame: self.navigationController!.navigationBar.frame)
        UIApplication.shared.keyWindow!.addSubview(sBar)
        
        sBar.delegate = self
        sBar.placeholder = "Search By Tag"
        sBar.showsCancelButton = true
        sBar.barStyle = .default
        sBar.searchBarStyle = .default
        sBar.tintColor = G_colorBlueLight
        sBar.barTintColor = G_colorBlueLight
        sBar.backgroundColor = G_colorBlueLight
        sBar.becomeFirstResponder()
        self.searchBar = sBar                
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.isSearching = false
        self.cln.reloadData()
        searchBar.resignFirstResponder()
        searchBar.removeFromSuperview()
        searchBar.delegate = nil
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let textInField = searchBar.text {
            
            searchBar.text = textInField
            
            let store = searchBar.text!
            
            if searchBar.text == "" {
                isSearching = false
                self.cln.reloadData()
            } else {
                isSearching = true
                filterContentForSearchText(store)
            }
        }
    }
    
    func filterContentForSearchText(_ searchText: String)
    {
        arrFilteredPhotos.removeAll()
        
        for photoObj in arrPhotos
        {
            for tag in photoObj.realmModel.tags.components(separatedBy: ",")
            {
                if tag.lowercased().contains(searchText.lowercased()) {
                    arrFilteredPhotos.append(photoObj)
                    break;
                }
            }
        }
        
        self.cln.reloadData()
    }
}
