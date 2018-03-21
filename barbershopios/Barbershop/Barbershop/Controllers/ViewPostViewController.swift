//
//  ViewPostViewController.swift
//  Barbershop
//
//  Created by user on 2017-07-07.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ViewPostViewController : UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var captionImageLabel: UILabel!
    
    var userKey : String?;
    var galleryKey : String?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationController?.navigationBar.barStyle = .black;
        self.navigationController?.navigationBar.tintColor = .black;
        
        let gradient = CAGradientLayer()
        
        gradient.frame = bottomView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        
        bottomView.layer.insertSublayer(gradient, at: 0)

        getPostInfo();
    }
    
    func getPostInfo()
    {
        let ref = Database.database().reference();
        
        ref.child("users").child(userKey!).child("gallery").child(galleryKey!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! String;
            
            self.captionImageLabel.text = value;

        });
        
        let storageRef = Storage.storage().reference();
        
        storageRef.child("users").child(userKey!).child("gallery").child(galleryKey!).downloadURL(completion: { (url, error) in
            
            if (url != nil)
            {
                self.imageView.kf.setImage(with: url);
            }
        });

    }
}
