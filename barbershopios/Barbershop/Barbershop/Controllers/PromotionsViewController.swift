//
//  PromotionsViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-23.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import IGListKit
import Firebase
import XLPagerTabStrip

class PromotionsViewController : UIViewController, ListAdapterDataSource, IndicatorInfoProvider
{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var backButton : UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBAction func back ()
    {
        self.viewDeckController?.open(.left, animated: true);
        // dismiss(animated: true, completion: nil);
    }
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0);
    }()
    
    var listOfPromotions = [Promotion]();
    var promotion : Promotion?;
    var mine = true;
    
    var userKey: String?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
       
        if (mine != true)
        {
            navigationItem.rightBarButtonItem = nil;
        }
        
        let backButton = UIBarButtonItem();
        backButton.title = "";
        self.navigationItem.backBarButtonItem = backButton;

        adapter.collectionView = collectionView;
        adapter.dataSource = self;
        
        if (listOfPromotions.count == 0)
        {
            getPromotions();
        }
    }
    
    func getPromotions()
    {
        let ref = Database.database().reference();
        
        ref.child("users").child(userKey!).child("promotions").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            var i = 0;
            
            if (value != nil)
            {
                for user in value!
                {
                    let promotionValue = user.value as! NSDictionary;
                    let promotionKey = user.key as! String;
                    
                    let bio = promotionValue["promodescription"] as! String;
                    
                    let newPromotion = Promotion();
                    
                    newPromotion.bio = bio;
                    newPromotion.promoKey = promotionKey
                    newPromotion.shopKey = self.userKey!;
                    newPromotion.pk = i;

                    i += 1;
                    self.listOfPromotions.append(newPromotion);
                }
                
                self.adapter.reloadData(completion: nil);
            }
        });
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        promotion = nil;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "NewPromotionSegue")
        {
            if (promotion == nil)
            {
                let vc = segue.destination as! ViewPromotionViewController;
                vc.new = true;
            }
            else
            {
                let vc = segue.destination as! ViewPromotionViewController;
                vc.promotion = promotion;
                vc.new = false;
            }
            
        }
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        // this can be anything!

        return listOfPromotions;
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sectionController = PromotionSectionController();
        sectionController.vc = self;
        
        return sectionController;
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "", image: #imageLiteral(resourceName: "ic_gallery"), highlightedImage: #imageLiteral(resourceName: "ic_gallery"));
    }

}
