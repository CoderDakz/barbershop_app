//
//  UploadGalleryViewController.swift
//  Barbershop
//
//  Created by user on 2017-07-07.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UploadGalleryViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var chooseImageLabel: UILabel!
    @IBOutlet weak var captionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let backButton = UIBarButtonItem();
        backButton.title = "Back";
        self.navigationItem.backBarButtonItem = backButton;
        
        self.navigationController?.navigationBar.barStyle = .black;
        self.navigationController?.navigationBar.tintColor = .white;

        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)));
        chooseImageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)));

        imageView.isUserInteractionEnabled = true;
        chooseImageLabel.isUserInteractionEnabled = true;
    }
    
    @IBAction func doneButton(sender: UIBarButtonItem)
    {
        if (imageView.image != nil)
        {
            let ref = Database.database().reference();
            let storageRef = Storage.storage().reference();
            let data = UIImageJPEGRepresentation(imageView.image!, 0.75);
            
            let galleryRef = ref.child("users").child(mainUser.key).child("gallery").childByAutoId();
            galleryRef.setValue(captionTextView.text!);
            
            self.view.makeToast("Uploading post...", duration: 1.0, position: .center);
            
            storageRef.child("users").child(mainUser.key).child("gallery").child(galleryRef.key).putData(data!, metadata: nil, completion: { (data, error) in
                
                self.view.makeToast("Post uploaded successfully!", duration: 1.0, position: .center);

                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute:
                    {
                        (self.navigationController?.viewControllers.first as! GalleryViewController).galleryKeys.append(galleryRef.key);
                        (self.navigationController?.viewControllers.first as! GalleryViewController).collectionView.reloadData();
                        self.navigationController?.popViewController(animated: true);

                });

            });
        }
    }
    
    // Choose image to upload with style
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
            imageView.image = image;
            chooseImageLabel.isHidden = true;
            
        }
        else
        {
            print("Something happened");
        }
        
        self.dismiss(animated: true, completion: nil);
    }

}
