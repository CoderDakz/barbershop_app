//
//  GalleryViewController.swift
//  Barbershop
//
//  Created by user on 2017-07-07.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import XLPagerTabStrip

class GalleryViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, IndicatorInfoProvider
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var galleryKeys = [String]();
    var userKey : String?;
    var selectedKey = 0;
    var mine : Bool?;
    let storageRef = Storage.storage().reference();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        let backButton = UIBarButtonItem();
        backButton.title = "";
        self.navigationItem.backBarButtonItem = backButton;

        if (mine! == false)
        {
            navigationItem.rightBarButtonItem = nil;
        }
        
        getGalleryKeys();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ViewPostSegue")
        {
            let viewController = segue.destination as! ViewPostViewController;
            
            viewController.galleryKey = galleryKeys[selectedKey];
            viewController.userKey = userKey;
        }
    }
    
    func getGalleryKeys()
    {
        let ref = Database.database().reference();
        
        ref.child("users").child(userKey!).child("gallery").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary;
            
            if (value != nil)
            {
                for user in value!
                {
                    self.galleryKeys.append(user.key as! String);
                }
                
                self.collectionView.reloadData();
            }

            self.collectionView.reloadData();
        });
        
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "UploadSegue", sender: self);
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem)
    {
        self.viewDeckController?.open(.left, animated: true);

        // self.dismiss(animated: true, completion: nil);
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryKeys.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell;
        
        storageRef.child("users").child(userKey!).child("gallery").child(galleryKeys[indexPath.row]).downloadURL(completion: { (url, error) in
            
            if (url != nil)
            {
                cell.imageView.kf.setImage(with: url);
            }
        });
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedKey = indexPath.row;
        self.performSegue(withIdentifier: "ViewPostSegue", sender: self);
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "", image: #imageLiteral(resourceName: "ic_gallery"), highlightedImage: #imageLiteral(resourceName: "ic_gallery"));
    }
}
