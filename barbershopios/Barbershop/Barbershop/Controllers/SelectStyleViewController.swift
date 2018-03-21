//
//  SelectStyleViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-19.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import IGListKit
import Firebase

class SelectStyleViewController : UIViewController, ListAdapterDataSource
{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0);
    }()
    
    
    var searchResults = [Style]();
    var appointment : Appointment?;
    var user : Shop?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        styleCart = [Style]();
        
        adapter.collectionView = collectionView;
        adapter.dataSource = self;
        
        if (styleCart.isEmpty)
        {
            nextButton.title = "";
            nextButton.isEnabled = false;
        }
        
        let backButton = UIBarButtonItem();
        backButton.title = "";
        backButton.tintColor = UIColor.white;
        
        self.navigationItem.backBarButtonItem = backButton;
        
        let gradient = CAGradientLayer();
        
        let secondColour = UIColor(red: 163.0/255.0, green: 170.0/255.0, blue: 179.0/255.0, alpha: 1.0).cgColor;
        let firstColour = UIColor(red: 62.0/255.0, green: 57.0/255.0, blue: 68.0/255.0, alpha: 1.0).cgColor;
                
        getShops();
        
        NotificationCenter.default.addObserver(self, selector: #selector(nextPressed), name: NSNotification.Name(rawValue: "stylepressed"), object: nil);
        
        
    }
    
    func nextPressed()
    {
        nextButton.title = "Next";
        nextButton.isEnabled = true;

    }
    
    func getShops()
    {
        if (user!.styles.count != 0 && user!.styles[0].name != "")
        {
            self.searchResults = user!.styles;
            
            return;
        }
        
        self.searchResults.removeAll();
        
        let ref = Database.database().reference();
        
        ref.child("users").child(mainShop.key).child("styles").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary;
            
            var newStyle : Style;
            
            if (value != nil)
            {
                var i = 0;
                
                for style in value!
                {
                    newStyle = Style();
                    
                    let currStyle = style.value as! NSDictionary;
                    
                    newStyle.name = style.key as! String;
                    newStyle.price = currStyle["price"] as! Double;
                    newStyle.details = currStyle["details"] as! String;
                    newStyle.time = currStyle["duration"] as! Int;
                    newStyle.key = style.key as! String;
                    newStyle.pk = i;
                    
                    i += 1;
                    self.searchResults.append(newStyle);
                }
            }
            
            mainShop.styles = self.searchResults;
            
            self.adapter.reloadObjects(self.searchResults);
            self.adapter.reloadData(completion: nil);
        });
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ConfirmBookingSegue")
        {
            let vc = segue.destination as! BookAppointmentViewController;
            
            vc.appointment = self.appointment;
            vc.user = user;
        }
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        // this can be anything!
        
        return searchResults;
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sectionController = SelectStyleSectionController();
        sectionController.vc = self;
        
        return sectionController;
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}
