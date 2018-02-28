//
//  settingVC.swift
//  ExScapeGoat
//
//  Created by q on 2/10/18.
//  Copyright © 2018 iWazowski.com. All rights reserved.
//

import UIKit

class settingVC: UITableViewController {

    @IBOutlet var imgIcon: customUIImageView!
    @IBOutlet var imgBackground: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = SettingManager.getBackgroundIndex {
            let imageName = "desktopoo" + index + ".jpg"
            if let image = UIImage.init(named: imageName) {
                imgBackground.image = image
            }
        }else {
            let imageName = "desktopoo0.jpg"
            if let image = UIImage.init(named: imageName) {
                imgBackground.image = image
            }
        }
        
        if let index = SettingManager.getIconIndex {
            let imageName = "ico_iconoo" + index
            if let image = UIImage.init(named: imageName) {
                imgIcon.image = image
            }
        }else {
            let imageName = "ico_iconoo0"
            if let image = UIImage.init(named: imageName) {
                imgIcon.image = image
            }
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapChangeIcon(_ sender: Any) {
        if let vc = G_getVc(ofType: changeAppIconVC(), FromStoryBoard: storyBoards.main , withIdentifier: vcIdentifiers.changeAppIconVC)
        {
            self.navigationController?.pushViewController(vc, animated: false)
            return;
        }
    }
    
    @IBAction func tapChangePassword(_ sender: Any) {
        if let vc = G_getVc(ofType: createPassword(), FromStoryBoard: storyBoards.main , withIdentifier: vcIdentifiers.CreatePassword) as? createPassword
        {
            vc.mode = 1
            self.navigationController?.pushViewController(vc, animated: false)
            return;
        }
    }
    
    @IBAction func tapChangeBackground(_ sender: Any) {
        if let vc = G_getVc(ofType: changeBackVC(), FromStoryBoard: storyBoards.main , withIdentifier: vcIdentifiers.changeBackVC)
        {
            
            self.navigationController?.pushViewController(vc, animated: false)
            return;
        }
    }
    
    @IBAction func tapBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
