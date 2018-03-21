//
//  MapViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-25.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase
import ViewDeck

class MapViewController : UIViewController, MKMapViewDelegate
{
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var results = [String:Shop]();

    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        map.delegate = self;
        
        let ref = Database.database().reference();
        
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary;
            
            for user in value
            {
                let currentUser = user.value as! NSDictionary;
                
                let type = currentUser["type"] as! Int;
                
                if (type == 3)
                {
                    let shop = Shop();
                    
                    shop.username = currentUser["username"] as! String;
                    shop.firstName = currentUser["shopname"] as! String;
                    shop.rating = currentUser["rating"] as! Double;
                    shop.email = currentUser["email"] as! String;
                    shop.phoneNumber = currentUser["phonenumber"] as! String;
                    shop.key = user.key as! String;
                    shop.address = Address();
                    shop.address.fullAddress = currentUser["shopaddress"] as! String;
                    
                    if (currentUser["aboutus"] != nil)
                    {
                        shop.bio = currentUser["aboutus"] as! String;
                    }
                    
                    if (currentUser["latitude"] != nil && currentUser["longitude"] != nil)
                    {
                        shop.latitude = currentUser["latitude"] as! Double;
                        
                        let marker = MKPointAnnotation();
                        let centerCoordinate = CLLocationCoordinate2D(latitude: shop.latitude!, longitude: shop.longitude!);
                        marker.coordinate = centerCoordinate;
                        marker.title = shop.firstName;
                        self.map.addAnnotation(marker);
                        
                        self.results[shop.firstName] = shop;
                    }
                }
            }
        });
    }
    
    @IBAction func back ()
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Test");
        pinView.animatesDrop = true;
        pinView.canShowCallout = true;
        
        pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure);
        
        return pinView;
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let viewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "NewProfileViewController") as! ProfileViewController;
        
        viewController.user = results[view.annotation!.title!!];
        
        let nviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuNewController");
        
        let viewDeck = IIViewDeckController(center: viewController, leftViewController: nviewController);
        
        self.present(viewDeck, animated: true, completion: nil);

        present(nviewController, animated: true, completion: nil);

    }
}

