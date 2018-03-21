//
//  ViewPromotionViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-24.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Kingfisher
// import FirebaseStorageUI


class ViewPromotionViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    @IBOutlet weak var promoDescription: UITextView!
    @IBOutlet weak var promoImage: UIImageView!
    @IBOutlet weak var chooseImageLabel: UILabel!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var new = false;
    var promotion: Promotion?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        promoDescription.text = "";
                
        self.navigationController?.navigationBar.barStyle = .black;
        self.navigationController?.navigationBar.tintColor = .black;
        
        if (!new)
        {
            promoDescription.isEditable = false;
            chooseImageLabel.isHidden = true;
            doneButton.isEnabled = false;
            navigationItem.rightBarButtonItem = nil;
            
            navigationItem.title? = "View Promotion";
            
            promoDescription.text = promotion!.bio;
            
            let storage = Storage.storage();
            let storageRef = storage.reference(withPath: "users/" + promotion!.shopKey + "/promotions/" + promotion!.promoKey);
            
            storageRef.downloadURL(completion: { (url, error) in
                
                if (url != nil)
                {
                    self.promoImage.kf.setImage(with: url);
                }
            });
        }
        else
        {
            promotion = Promotion();
            chooseImageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)));
            promoImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)));
            promoImage.isUserInteractionEnabled = true;
            chooseImageLabel.isUserInteractionEnabled = true;
        }
    }
    
    @IBAction func done()
    {
        let ref = Database.database().reference();
        
        promotion!.bio = promoDescription.text!;
        
        let reference = ref.child("users").child(mainUser.key).child("promotions").childByAutoId();
        
        reference.setValue(promotion!.bio);
        
        let key = reference.key;
        
        promotion!.promoKey = key;
        
        if (promoImage.image != nil)
        {
            promotion!.image = promoImage.image;
            
            let data = UIImageJPEGRepresentation(promoImage.image!, 0.8);
            
            let storageRef = Storage.storage().reference();
            
            storageRef.child("users").child(mainUser.key).child("promotions").child(key).putData(data!, metadata: nil, completion: { (storage, error) in
                
                // Add promotion to our
                self.navigationController?.popViewController(animated: true);
            });
        }
        
        promotion!.pk = (mainUser as! Shop).promotions.count;
        
        (mainUser as! Shop).promotions.append(self.promotion!);
        
        (self.navigationController?.viewControllers.first as! PromotionsViewController).listOfPromotions = (mainUser as! Shop).promotions;
        (self.navigationController?.viewControllers.first as! PromotionsViewController).adapter.reloadObjects((self.navigationController?.viewControllers.first as! PromotionsViewController).listOfPromotions);
        (self.navigationController?.viewControllers.first as! PromotionsViewController).adapter.reloadData(completion: nil);
        
        self.navigationController?.popViewController(animated: true);
    }
    
    func chooseImage()
    {
        let imagePicker = UIImagePickerController();
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)
            
            let libraryAction = UIAlertAction(title: "Choose Image", style: .default) { (action) in
                
                imagePicker.sourceType = .photoLibrary;
                
                imagePicker.allowsEditing = true;
                imagePicker.delegate = self;
                
                self.present(imagePicker, animated: true, completion: nil);
            }
            alertController.addAction(libraryAction)
            
            let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { (action) in
                
                imagePicker.sourceType = .camera;
                
                imagePicker.allowsEditing = true;
                imagePicker.delegate = self;
                
                self.present(imagePicker, animated: true, completion: nil);
                
            }
            alertController.addAction(cameraAction)
            
            self.present(alertController, animated: true, completion: nil);
        }
        else
        {
            imagePicker.sourceType = .photoLibrary;
            
            imagePicker.delegate = self;
            
            present(imagePicker, animated: true, completion: nil);
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            promoImage.image = image;
            chooseImageLabel.isHidden = true;

        }
        else
        {
            print("Something happened");
        }

        self.dismiss(animated: true, completion: nil);
    }
}
