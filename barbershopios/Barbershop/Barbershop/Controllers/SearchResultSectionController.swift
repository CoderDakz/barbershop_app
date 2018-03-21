//
//  SearchResultSectionController.swift
//  Barbershop
//
//  Created by user on 2017-06-04.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import IGListKit
import Firebase
import CoreLocation
import ViewDeck
import Kingfisher

class SearchResultSectionController: ListSectionController, CLLocationManagerDelegate {
    private var object: Shop!
    private var latitude: Double?;
    private var longitude: Double?;
    
    var vc : UIViewController?;
    let locationManager = CLLocationManager()
    var reload = false;
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func numberOfItems() -> Int {
        return 1;
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: 375, height: 113)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCellFromStoryboard(withIdentifier: "SearchResultCell", for: self, at: index) as! SearchResultCell;
        
        if (latitude != nil || longitude != nil)
        {
            let distance1 = CLLocation(latitude: latitude!, longitude: longitude!);
            let distance2 = CLLocation(latitude: object.latitude!, longitude: object.longitude!);
            
            let distanceString = String(format: "%.1f", distance1.distance(from: distance2)/1000);
            
            cell.userDistance.text = "\(distanceString) km away";
        }
        
        cell.userName.text = "\(self.object.firstName) \(self.object.lastName)";
        cell.userRating.rating = Double(object!.rating);
        
        cell.layer.borderColor = UIColor.gray.cgColor;
        cell.layer.borderWidth = 1;
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath;
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell.layer.shadowRadius = 1
        cell.layer.shouldRasterize = true;

        let storage = Storage.storage();
        let storageRef = storage.reference(withPath: "users/" + object!.key + "/avatar.jpeg");
        
        storageRef.downloadURL(completion: { (url, error) in
        
            if (url != nil)
            {
                cell.profilePicture.kf.setImage(with: url);
            }
        });
        // cell.profilePicture.sd_setImage(with: storageRef);

        // cell.userRating.rating = Double((object as! Shop).rating);

        return cell;
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as! Shop;
        print("Selected index \(self.object.firstName) \(self.object.lastName)");
    }
    
    override func didSelectItem(at index: Int) {
        
        let nviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuController");
        let viewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "NewerProfileViewController") as! NewerProfileViewController;
        
        viewController.user = self.object!;
        mainShop = self.object!;
        
        let sideController = IIViewDeckController(center: viewController, leftViewController: nviewController);

        vc?.present(sideController, animated: true, completion: nil);

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitude = manager.location?.coordinate.latitude;
        longitude = manager.location?.coordinate.longitude;

        if (reload == false)
        {
            collectionContext?.performBatch(animated: true, updates: { (batchContext) in
                self.reload = true;
                batchContext.reload(self)
            })
        }
        
    }
}
