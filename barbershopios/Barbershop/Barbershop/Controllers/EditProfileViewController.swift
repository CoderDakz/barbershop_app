//
//  EditProfileViewController.swift
//  Barbershop
//
//  Created by user on 2017-07-03.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EditProfileViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changeProfileButton: UIButton!
    @IBOutlet weak var removeProfileButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.hideKeyboardWhenTappedAround();
        
        let backButton = UIBarButtonItem();
        backButton.title = "";
        self.navigationItem.backBarButtonItem = backButton;
        
        self.navigationController?.navigationBar.barStyle = .black;
        self.navigationController?.navigationBar.tintColor = .black;

        if (mainUser.profilePic == nil)
        {
            let ref = Storage.storage().reference();
            
            ref.child("users").child(mainUser.key).child("avatar.jpeg").downloadURL(completion: { (url, error) in
                if (url != nil)
                {
                    self.profileImageView.kf.setImage(with: url!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (completion) in
                        mainUser.profilePic = self.profileImageView.image!;
                    });
                }
            });
            
        }
        
        usernameField.text = mainUser.username;
        emailField.text = mainUser.email;
        descriptionField.text = mainUser.bio;
        
        usernameField.delegate = self;
        emailField.delegate = self;
    }
 
    @IBAction func doneButton(sender: UIBarButtonItem)
    {
        let ref = Database.database().reference();
        
        if (emailField.text != mainUser.email)
        {
            Auth.auth().currentUser?.updateEmail(to: emailField.text!, completion: nil);
        }
        
        if (self.profileImageView.image == nil && mainUser.profilePic != nil)
        {
            let storage = Storage.storage().reference(withPath: "users/" + mainUser.key + "/avatar.jpeg");
            
            storage.delete(completion: nil);
        }
        else if (self.profileImageView.image != mainUser.profilePic)
        {
            let storage = Storage.storage().reference(withPath: "users/" + mainUser.key + "/avatar.jpeg");
            let data = UIImageJPEGRepresentation(self.profileImageView.image!, 0.6);
            
            storage.putData(data!, metadata: nil, completion: nil);
        }
        
        let myRef = ref.child("users").child(mainUser.key);
        myRef.child("email").setValue(emailField.text!);
        myRef.child("username").child(usernameField.text!);
        myRef.child("description").child(descriptionField.text!);
        
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func chooseImage(sender: UIButton)
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
    
    @IBAction func removeImage()
    {
        profileImageView.image = nil;
        mainUser.profilePic = nil;
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            profileImageView.image = image;
        }
        else
        {
            print("Something happened");
        }
        
        self.dismiss(animated: true, completion: nil);
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard();
        
        return true;
    }

}
