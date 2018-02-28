//
//  changeBackVC.swift
//  ExScapeGoat
//
//  Created by q on 2/10/18.
//  Copyright © 2018 iWazowski.com. All rights reserved.
//

import UIKit

class changeBackVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let index = SettingManager.getBackgroundIndex {
            self.index = index
        }
        
        let btn = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(changeBackVC.save(_:)))
        self.navigationItem.rightBarButtonItems = [btn]
        let nib = UINib.init(nibName: "BackgroundCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
        flowLayout.itemSize = CGSize.init(width: 100, height: 176)
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 18
    }
    
    @objc open func save(_ sender: UIView) {
        SettingManager.set(BackgroundIndex: self.index)
        self.navigationController?.popViewController(animated: true)
    }
    
    var index:String = "0"

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 12
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BackgroundCollectionViewCell
        let imageName = "desktopoo\(indexPath.row).jpg"
        if let image = UIImage.init(named: imageName) {
            cell.imgBack.image = image
        }
        cell.imgTick.isHidden = true
        if let index = Int(self.index) {
            if index == indexPath.row {
                cell.imgTick.isHidden = false
            }
        }
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.index = "\(indexPath.row)"
        self.collectionView.reloadData()
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
