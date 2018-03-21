//
//  UploadProfileView.swift
//  Barbershop
//
//  Created by user on 2017-06-28.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UploadProfileView : UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var chooseImage: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    var vc : UIViewController?;
    
    @IBAction func chooseProfilePic()
    {
        /*
         This block of code is used to get an image, either by camera (if it's available) or in the
         iPhone storage.
        */
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
                imagePicker.modalPresentationStyle = .overFullScreen;
                
                self.vc?.present(imagePicker, animated: true, completion: nil);
            }
            alertController.addAction(libraryAction)
            
            let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { (action) in
                
                imagePicker.sourceType = .camera;
                
                imagePicker.allowsEditing = true;
                imagePicker.delegate = self;
                imagePicker.modalPresentationStyle = .overFullScreen;
                
                self.vc?.present(imagePicker, animated: true, completion: nil);
                
            }
            alertController.addAction(cameraAction)
            
            self.vc?.present(alertController, animated: true, completion: nil);
        }
        else
        {
            imagePicker.sourceType = .photoLibrary;
            imagePicker.delegate = self;
            imagePicker.modalPresentationStyle = .overFullScreen;
            
            self.vc?.present(imagePicker, animated: true, completion: nil);
        }
    }
    
    @IBAction func skipPressed()
    {
        // If user skips, set standard value to true so user doesn't get asked again
        UserDefaults.standard.setValue(true, forKey: "registered");
        vc?.dismiss(animated: true, completion: nil);
    }
    
    // If user submits a picture, then upload it to server and save the picture to our user variable
    @IBAction func submitPressed()
    {
        let ref = Storage.storage();
        
        let data = UIImageJPEGRepresentation(imageView.image!, 0.8);
        
        ref.reference(withPath: "users/" + mainUser.key + "/avatar.jpeg").putData(data!, metadata: nil, completion: { (metadata, error) in
            UserDefaults.standard.setValue(true, forKey: "registered");
            
        })
        
        mainUser.profilePic = imageView.image!;
        vc?.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // If we got a UIImage, then save it to our image view
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imageView.image = image;
        }
        else
        {
            print("Something happened");
        }
        
        vc?.dismiss(animated: true, completion: nil);
    }
    
    // Make UI changes to view
    func makeLayoutChangesToView()
    {
        self.roundCorners(5.0);
        self.submitButton.roundCorners(3.0);
    }
}
