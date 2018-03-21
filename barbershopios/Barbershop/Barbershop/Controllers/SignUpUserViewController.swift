//
//  SignUpUserViewController.swift
//  Barbershop
//
//  Created by user on 2017-07-13.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation
import ViewDeck

class SignUpUserViewController : UIViewController, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate
{
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var barberSwitch: UISwitch!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var hairstylistLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    var isShop = false;
    let locationManager = CLLocationManager()
    let datePicker = UIDatePicker();
    
    var latitude : Double?;
    var longitude : Double?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let backButton = UIBarButtonItem();
        backButton.title = "";
        self.navigationItem.backBarButtonItem = backButton;

        imageView.roundCorners(40.0);
        
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged);
        dobTextField.inputView = datePicker;

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 23/255, green: 22/255, blue: 32/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        dobTextField.inputAccessoryView = toolBar;
        
        firstNameTextField.delegate = self;
        lastNameTextField.delegate = self;
        emailTextField.delegate = self;
        usernameTextField.delegate = self;
        passwordTextField.delegate = self;
        
        if (isShop)
        {
            signUpButton.setTitle("Next", for: .normal);
        }
        
        uploadLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)));
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)));
        uploadLabel.isUserInteractionEnabled = true;
        imageView.isUserInteractionEnabled = true;

        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            locationManager.delegate = self;
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SignUpBusinessViewController;
        
        let shop = Shop();
        shop.username = usernameTextField.text!;
        shop.email = emailTextField.text!;
        shop.firstName = firstNameTextField.text!;
        shop.lastName = lastNameTextField.text!;
        shop.type = barberSwitch.isOn ? 2 : 1;
        shop.password = passwordTextField.text!;
        
        if (imageView.image != nil)
        {
            shop.profilePic = imageView.image!;
        }
        
        viewController.shop = shop;
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        if (!isShop)
        {
            registerUser();
        }
        else
        {
            performSegue(withIdentifier: "BusinessSegue", sender: self);
        }
    }
    
    @IBAction func back(sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    func registerUser()
    {
        var paramToSend = ["email" : emailTextField.text!, "username" : usernameTextField.text!, "birthdate" : dobTextField.text!, "fullname" : firstNameTextField.text! + " " + lastNameTextField.text!, "type" : barberSwitch.isOn ? 2 : 1] as [String : Any];
        
        if (self.latitude != nil)
        {
            paramToSend["latitude"] = self.latitude!
        }
        
        if (self.longitude != nil)
        {
            paramToSend["longitude"] = self.longitude!
        }
        
        // If this is a barber, send a new empty schedule to the server
        if ((paramToSend["type"] as! Int) == 2)
        {
            let time = TimeSlot();
            
            paramToSend["schedule"] = time.scheduleToString();
        }
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            let ref = Database.database().reference();
            
            if (user == nil)
            {
                print(error?.localizedDescription);
            }
            
            if (self.barberSwitch.isOn == true)
            {
                mainUser = Barber();
                (mainUser as! Barber).schedule.stringToSchedule(string: paramToSend["schedule"] as! String);
            }
            else
            {
                mainUser = User();
            }
            
            let defaults = UserDefaults.standard;
            
            mainUser.key = user!.uid;
            mainUser.email = self.emailTextField.text!;
            mainUser.username = self.usernameTextField.text!;
            mainUser.firstName = paramToSend["fullname"] as! String;
            mainUser.latitude = self.latitude;
            mainUser.longitude = self.longitude;
            mainUser.type = self.barberSwitch.isOn ? 2 : 1;
            
            // Push all of our set parameters to the server
            ref.child("users").child(user!.uid).setValue(paramToSend);
            
            defaults.setValue(user!.uid, forKey: "user_id");
            defaults.setValue( false, forKey: "registered");
            
            if (defaults.synchronize() == false)
            {
                print("Didnt save");
            }
            
            DispatchQueue.main.async {
                self.view.makeToast("Successfully Logged in...", duration: 2.0, position: .center)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute:
                {
                    
                    let moreInfoViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "MyNewerProfileViewController");
                    
                    let nviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuNewController");
                    
                    let sideController = IIViewDeckController(center: moreInfoViewController, leftViewController: nviewController);
                    
                    self.present(sideController, animated: false, completion: nil);
            })
            
            
        });
    }
    
    func donePicker()
    {
        dobTextField.resignFirstResponder();
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        latitude = manager.location?.coordinate.latitude;
        longitude = manager.location?.coordinate.longitude;
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription);
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
            imageView.image = image;
            uploadLabel.isHidden = true;
            
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
    
    func dateChanged()
    {
        dobTextField.text = shortDateFormatter.string(from: self.datePicker.date);
    }

}
