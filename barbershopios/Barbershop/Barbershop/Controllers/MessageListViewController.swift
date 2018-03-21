//
//  MessageListViewController.swift
//  Barbershop
//
//  Created by user on 2017-07-01.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MessageListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    var messageKey : String?;
    var messageName : String?;
    var messageNames = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        grabMessageNames();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        if (tableView.indexPathForSelectedRow != nil)
        {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: false);
        }
    }
    
    func grabMessageNames()
    {
        let ref = Database.database().reference();
        
        for message in mainUser.messageList
        {
            ref.child("messages").child(message).child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary;
                
                if (value != nil)
                {
                    for user in value!
                    {
                        let currentUser = user.value as! String;
                        
                        if (currentUser != mainUser.firstName)
                        {
                            self.messageNames.append(currentUser);
                        }
                    }
                    
                    self.tableView.reloadData();
                }
            });
        }
    }
    
    @IBAction func backButton(sender: UIBarButtonItem)
    {
        self.viewDeckController?.open(.left, animated: true);

        // dismiss(animated: true, completion: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! ChatViewController;
        
        viewController.messageKey = messageKey!;
        viewController.messageName = messageName!;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageListCell", for: indexPath) as! MessageListCell;
        
        if (messageNames.count > indexPath.row)
        {
            cell.userName.text = messageNames[indexPath.row];
        }
        
        cell.unread_icon.roundCorners(8.0);
        cell.unread_icon.isHidden = true;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainUser.messageList.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageKey = mainUser.messageList[indexPath.row];
        messageName = messageNames[indexPath.row];
                
        self.performSegue(withIdentifier: "MessageSegue", sender: self);
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete)
        {
            let ref = Database.database().reference();
            
            let key = mainUser.messageList[indexPath.row];
            mainUser.messageList.remove(at: indexPath.row);
            
            ref.child("messages").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as! NSDictionary;
                
                for user in (value["users"] as! NSDictionary)
                {
                    let currentKey = user.value as! String;
                    
                    ref.child("users").child(currentKey).child("messages").child(key).removeValue();
                }
                
                ref.child("messages").child(key).removeValue();
                
                self.tableView.deleteRows(at: [indexPath], with: .automatic);
            });
        }
    }
    
    @IBAction func addButton(sender: UIBarButtonItem)
    {
        let alertController = UIAlertController(title: "Search User", message: "Enter user you would like to message:", preferredStyle: .alert);
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "User name";
            textField.clearButtonMode = .whileEditing;
            textField.borderStyle = .roundedRect;
        });
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            
            // Get name user has chosen
            let query = alertController.textFields?[0].text!;
            
            let ref = Database.database().reference();
            
            /*
             Search through the database for the shop name that has the query. Search by type 3 which is the shops.
             \u{f8ff} is some next hex code that I forgot but it makes search works
             */
            ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: query!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                // Get the current snapshot which is a Dictionary of the search results in the database. Create the unique key variable
                
                let value = snapshot.value as? NSDictionary

                if (value != nil)
                {
                    // self.messageKey = snapshot.key;
                    for user in value!
                    {
                        let currentUser = user.value as! NSDictionary;
                        
                        let messageRef = ref.child("messages").childByAutoId();
                        
                        self.messageKey = messageRef.key;
                        self.messageName = currentUser["fullname"] as! String;
                        
                        ref.child("users").child(mainUser.key).child("messages").childByAutoId().setValue(self.messageKey);
                        ref.child("users").child(user.key as! String).child("messages").childByAutoId().setValue(self.messageKey);
                        messageRef.child("users").child(mainUser.key).setValue(mainUser.firstName);
                        messageRef.child("users").child(user.key as! String).setValue(self.messageName);
                        mainUser.messageList.append(self.messageKey!);
                        self.tableView.reloadData();
                        
                        self.performSegue(withIdentifier: "MessageSegue", sender: self);

                    }
                }
                else
                {
                    self.view.makeToast("Sorry, that user does not exist.", duration: 1.5, position: .center);
                }
                
            });
        });
        
        alertController.addAction(cancelAction)
        alertController.addAction(okayAction);
        
        self.present(alertController, animated: true, completion: nil);

    }
}
