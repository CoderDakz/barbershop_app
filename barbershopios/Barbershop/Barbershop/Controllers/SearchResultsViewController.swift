//
//  SearchResultsViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-04.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class SearchResultsViewController: UIViewController, ListAdapterDataSource
{
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0);
    }()
    
    var searchResults : [Shop]?;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();

        // view.addSubview(collectionView)

        adapter.collectionView = searchCollectionView;
        adapter.dataSource = self;
        
    }
    
    @IBAction func backButton(sender: UIBarButtonItem)
    {
        dismiss(animated: true, completion: nil);
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        // this can be anything!

        return searchResults!;
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let viewController = SearchResultSectionController();
        
        viewController.vc = self;
        
        return viewController;
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}
