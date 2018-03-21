//
//  NewStyleViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-30.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewStyleViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var detailsField: UITextView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var chooseImageLabel: UILabel!
    
    var timeSelected : Int?;
    var new = true;
    var style : Style?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.hideKeyboardWhenTappedAround();
        
        // Change Back button inside the navigation bar
        let backButton = UIBarButtonItem();
        backButton.title = "Back";
        self.navigationItem.backBarButtonItem = backButton;
        
        self.navigationController?.navigationBar.barStyle = .black;
        self.navigationController?.navigationBar.tintColor = .black;
        
        // Create Picker view for selecting times
        let pickerView = UIPickerView();
        pickerView.tag = 0;
        pickerView.dataSource = self;
        pickerView.delegate = self;

        // Create toolbar for user to select done
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 23/255, green: 22/255, blue: 32/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        timeField.inputView = pickerView;
        timeField.inputAccessoryView = toolBar;

        detailsField.text = "";
        
        priceField.delegate = self;
        timeField.delegate = self;
        nameField.delegate = self;
        
        // If the style is not new, place information inside text fields
        if (!new)
        {
            priceField.text = "\(style!.price)";
            nameField.text = style!.name;
            timeField.text = timeIntervals[style!.time];
            detailsField.text = style!.details;
            timeSelected = style!.time;
            chooseImageLabel.isHidden = true;
            
            self.navigationItem.title = "Edit Style";
        }
    }
    
    // When user selects done, upload style to the server
    @IBAction func doneButton(sender: UIBarButtonItem)
    {
        let ref = Database.database().reference();
        let newStyle = Style();
        
        if (new)
        {
            let paramSend = ["name" : nameField.text!, "price" : Double(priceField.text!), "details" : detailsField.text!, "time": timeSelected!] as [String : Any];
            
            newStyle.details = paramSend["details"] as! String;
            newStyle.price = paramSend["price"] as! Double;
            newStyle.name = paramSend["name"] as! String;
            newStyle.time = paramSend["time"] as! Int;
            
            
            ref.child("users").child(mainUser.key).child("styles").child(newStyle.name).setValue(paramSend);
            (mainUser as! Shop).styles.append(newStyle);
            
            self.dismiss(animated: true, completion: nil);

        }
        else
        {
            let paramSend = ["name" : nameField.text!, "price" : Double(priceField.text!), "details" : detailsField.text!, "time": timeSelected!] as [String : Any];
            
            newStyle.details = paramSend["details"] as! String;
            newStyle.price = paramSend["price"] as! Double;
            newStyle.name = paramSend["name"] as! String;
            newStyle.time = paramSend["time"] as! Int;
            newStyle.key = style!.key;

            ref.child("users").child(mainUser.key).child("styles").child(newStyle.key).setValue(paramSend);

            let index = (mainUser as! Shop).styles.index(of: style!);

            (mainUser as! Shop).styles.remove(at: index!);
            (mainUser as! Shop).styles.append(newStyle);
            
            self.navigationController?.popViewController(animated: true);
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

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeIntervals.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timeField.text = timeIntervals[row];
        timeSelected = row + 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeIntervals[row];
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func donePicker(sender: UIBarButtonItem)
    {
        timeField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard();
        
        return true;
    }
    
}
