//
//  ViewRatingsViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-29.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class ViewRatingsViewController : UIViewController, ListAdapterDataSource
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0);
    }()
    
    var reviews = [Review]();

    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        adapter.collectionView = collectionView;
        adapter.dataSource = self;
        
    }
    
    @IBAction func backButton(sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return reviews;
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ReviewSectionController();
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
