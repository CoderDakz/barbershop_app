//
//  NewerProfileViewController.swift
//  Barbershop
//
//  Created by user on 2017-08-25.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
import Firebase

class NewerProfileViewController : BaseButtonBarPagerTabStripViewController<ProfileIconCell>
{
    @IBOutlet weak var mainNavigationBar: UINavigationBar!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var bookAppointmentButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var callButton: UIView!
    @IBOutlet weak var emailButton: UIView!
    @IBOutlet weak var locationButton: UIView!
    
    var userKey : String?;
    var user : Shop?;
    var promos = [Promotion]();

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: "ProfileIconCell", bundle: Bundle(for: ProfileIconCell.self), width: { _ in
            return 48.0
        })
    }

    override func viewDidLoad() {
        
        // Configurations for the tabs
        settings.style.buttonBarItemBackgroundColor = UIColor.white;
        settings.style.buttonBarItemFont = UIFont.boldSystemFont(ofSize: 14);
        settings.style.selectedBarHeight = 2.0;
        settings.style.buttonBarItemTitleColor = .black;
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0

        changeCurrentIndexProgressive = { [weak self] (oldCell: ProfileIconCell?, newCell: ProfileIconCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.iconImage!.tintColor = UIColor.gray;
            newCell?.iconImage!.tintColor = UIColor.black;
        }

        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: "ProfileIconCell", bundle: Bundle(for: ProfileIconCell.self), width: { _ in
            return 48.0
        })
        
        // Design configurations
        sendMessageButton.roundCorners(5.0);
        bookAppointmentButton.roundCorners(5.0);
        
        // Plugging information into objects
        
        mainNavigationBar.topItem?.title = user?.firstName;
        descriptionTextView.text = user?.bio;
        
        if (user != nil)
        {
            let storage = Storage.storage();
            let storageRef = storage.reference(withPath: "users/" + user!.key + "/avatar.jpeg");
            
            storageRef.downloadURL(completion: { (url, error) in
                
                if (url != nil)
                {
                    self.profilePicture.kf.setImage(with: url);
                }
                else
                {
                    self.profilePicture.image = #imageLiteral(resourceName: "UserPlaceholderimg");
                }
            });
        }
        
        // Get all of users promotions
        getPromotions();
        
        // Add ability to click call, email, and location views
        callButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(callAction)));
        emailButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emailAction)));
        locationButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationAction)));

        super.viewDidLoad();
    }
    
    func getPromotions()
    {
        let ref = Database.database().reference();
        
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            var i = 0;
            
            if (value != nil)
            {
                for user in value!
                {
                    let currUser = user.value as! NSDictionary;
                    
                    let promotions = currUser["promotions"] as? NSDictionary;
                    
                    if (promotions != nil)
                    {
                        for promotion in promotions!
                        {
                            print(promotion);
                            let currPromotion = promotion.value as! NSDictionary;
                            
                            let bio = currPromotion["promodescription"] as! String;
                            
                            let newPromotion = Promotion();
                            
                            newPromotion.bio = bio;
                            newPromotion.promoKey = promotion.key as! String
                            newPromotion.shopKey = user.key as! String;
                            newPromotion.pk = i;
                            
                            i += 1;
                            self.promos.append(newPromotion);
                            
                        }
                    }
                }
            }
        });

    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let viewController1 = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileExtrasVC") as! ProfileExtrasVC;
        let viewController2 = UIStoryboard.init(name: "SocialMediaStoryboard", bundle: nil).instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController;
        let viewController3 = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileExtrasVC") as! ProfileExtrasVC;

        viewController1.isPromotions = true;
        viewController1.userKey = user!.key;
        viewController2.mine = false;
        viewController2.userKey = user!.key;
        viewController3.isPromotions = false;
        viewController3.userKey = user!.key;
        
        return [viewController2, viewController1, viewController3];
    }
    
    override func configure(cell: ProfileIconCell, for indicatorInfo: IndicatorInfo) {
        cell.iconImage.image = indicatorInfo.image?.withRenderingMode(.alwaysTemplate);
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        if indexWasChanged && toIndex > -1 && toIndex < viewControllers.count {
            let child = viewControllers[toIndex] as! IndicatorInfoProvider // swiftlint:disable:this force_cast
            UIView.performWithoutAnimation({ [weak self] () -> Void in
                guard let me = self else { return }
                me.navigationItem.leftBarButtonItem?.title =  child.indicatorInfo(for: me).title
            })
        }
    }
    
    func callAction()
    {
        if let url = URL(string: "tel://\(user!.phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func emailAction()
    {
        if let url = URL(string: "mailto://\(user!.email)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func locationAction()
    {
        let address = user!.address.fullAddress
        
        UIApplication.shared.openURL(NSURL(string: "http://maps.apple.com/?address=" + address.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)! as URL)
        
    }
    
    @IBAction func messageAction()
    {
        let ref = Database.database().reference();
        
        let messageRef = ref.child("messages").childByAutoId();
        
        let messageKey = messageRef.key;
        let messageName = user!.firstName;
        
        ref.child("users").child(mainUser.key).child("messages").childByAutoId().setValue(messageKey);
        ref.child("users").child(user!.key).child("messages").childByAutoId().setValue(messageKey);
        messageRef.child("users").child(mainUser.key).setValue(mainUser.firstName);
        messageRef.child("users").child(user!.key).setValue(messageName);
        mainUser.messageList.append(messageKey);
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController;
        
        viewController.messageKey = messageKey;
        viewController.messageName = messageName;
        
        self.present(viewController, animated: true, completion: nil);
    }
    
    @IBAction func bookAppointmentAction()
    {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookAppointmentNavigationController") as! BookAppointmentNavigationController;
        
        viewController.user = user;
        
        self.present(viewController, animated: true, completion: nil);
    }
    
    @IBAction func dismissViewController(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    
}
