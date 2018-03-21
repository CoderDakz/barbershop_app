//
//  ProfileGalleryViewController.swift
//  Barbershop
//
//  Created by user on 2017-08-25.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

class ProfileGalleryViewController : UICollectionViewController, IndicatorInfoProvider
{
    init()
    {
        super.init(collectionViewLayout: UICollectionViewFlowLayout());
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell;
        
        cell.contentView.backgroundColor = UIColor.black;
        
        return cell;
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "", image: UIImage(named: "ic_gallery"), highlightedImage: UIImage(named: "ic_gallery"));
    }
}
