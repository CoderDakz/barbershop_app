//
//  ProfileExtrasVC.swift
//  Barbershop
//
//  Created by user on 2017-09-05.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import XLPagerTabStrip

class ProfileExtrasVC : UITableViewController, IndicatorInfoProvider
{
    
    var isPromotions = false;
    var userKey : String?;
    
    var promotions = [Promotion]();
    var users = [Barber]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if (isPromotions)
        {
            getPromotions();
        }
        
        tableView.tableFooterView = UIView();
    
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
                    self.promotions.append(newPromotion);
                }
                
                self.tableView.reloadData();
            }
        });
    }
    
    func getEmployees()
    {
        let ref = Database.database().reference();
        
        ref.child("users").child(userKey!).child("barbers").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary;
            
            if (value != nil)
            {
                for barberKey in (value!.allValues as! [String])
                {
                    ref.child("users").child(barberKey).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary;
                        
                        if (value != nil)
                        {
                            let barber = Barber();
                            
                            barber.schedule.stringToSchedule(string: value!["schedule"] as! String);
                            barber.firstName = value!["fullname"] as! String;
                            barber.username = value!["username"] as! String;
                            barber.key = snapshot.key;
                            
                            self.users.append(barber);
                            
                            self.tableView.reloadData();

                        }
                    });
                }
            }
        });
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (isPromotions)
        {
            return 220.0;
        }
        else
        {
            return 62.0;
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isPromotions)
        {
            return promotions.count;
        }
        else
        {
            return users.count;
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (isPromotions)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePromotionCell", for: indexPath) as! ProfilePromotionCell;
            
            let promotion = promotions[indexPath.row];
            
            cell.promotionTitle.text = promotion.bio;
            
            let storage = Storage.storage();
            let storageRef = storage.reference(withPath: "users/" + promotion.shopKey + "/promotions/" + promotion.promoKey);
            
            storageRef.downloadURL(completion: { (url, error) in
                
                if (url != nil)
                {
                    cell.promotionImg.kf.setImage(with: url);
                }
            });

            return cell;
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEmployeeCell", for: indexPath) as! ProfileEmployeeCell;
            
            let barber = users[indexPath.row];
            
            cell.userName.text = barber.firstName;
            
            let storage = Storage.storage();
            let storageRef = storage.reference(withPath: "users/" + barber.key + "/avatar.jpeg");

            storageRef.downloadURL(completion: { (url, error) in
                
                if (url != nil)
                {
                    cell.profilePicture.kf.setImage(with: url);
                }
            });
            
            return cell;
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        if (isPromotions)
        {
            return IndicatorInfo(title: "", image: UIImage(named: "ic_promotions"), highlightedImage: UIImage(named: "ic_promotions"));
        }
        else
        {
            return IndicatorInfo(title: "", image: UIImage(named: "ic_search_name"), highlightedImage: UIImage(named: "ic_search_name"));
        }
    }
}
