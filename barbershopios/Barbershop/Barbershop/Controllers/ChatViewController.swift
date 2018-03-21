//
//  ChatViewController.swift
//  Barbershop
//
//  Created by user on 2017-07-01.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController : JSQMessagesViewController
{
 
    // MARK: Initializers
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var messages = [JSQMessage]();
    var messageKey : String?;
    var messageName : String?;
    var amount = 0;
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.senderId = mainUser.key;
        self.senderDisplayName = "Hey";

        if (messageName != nil)
        {
            self.title = messageName;
        }
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        let backButton = UIBarButtonItem();
        backButton.title = "Back";
        self.navigationItem.backBarButtonItem = backButton;
        
        self.navigationController?.navigationBar.barStyle = .black;
        self.navigationController?.navigationBar.tintColor = .black;
        
        self.inputToolbar.contentView.leftBarButtonItem = nil;
        // self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(UIColor(red: 146/255, green: 121/255, blue: 255/255, alpha: 1), for: .normal);

        grabMessages();
    }
    
    func grabMessages()
    {
        let ref = Database.database().reference();
        
        ref.child("messages").child(messageKey!).observe(.childAdded, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary;

            if (value != nil)
            {
                if (snapshot.key != "users")
                {
                    if (value!["time"] != nil)
                    {
                        let date = Date(milliseconds: value!["time"] as! Int)
                            
                        self.addMessageWithDate(withId: value!["senderid"] as! String, name: "Test", text: value!["message"] as! String, date: date);
                    }
                    else
                    {
                        self.addMessage(withId: value!["senderid"] as! String, name: "Test", text: value!["message"] as! String);
                    }
                }
            }
            else
            {
                self.amount = snapshot.value as! Int;
            }
            
            self.finishReceivingMessage();
        });
        
        ref.child("messages").child(messageKey!).observe(.childChanged, with: { (snapshot) in
            let value = snapshot.value as? Int;
            
            if (value != nil)
            {
                self.amount = value!;
            }
        });
    }
    
    // MARK: Custom functions
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor(red: 146/255, green: 121/255, blue: 255/255, alpha: 1))
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func addMessageWithDate(withId id: String, name: String, text: String, date: Date) {
        if let message = JSQMessage(senderId: id, senderDisplayName: mainUser.firstName, date: date, text: text)
        {
            messages.append(message);
        }
    }
    
    // MARK: Delegation and Data Source
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item];
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let ref = Database.database().reference();
        
        let paramSend = ["senderid" : self.senderId, "message" : text, "time" : date.millisecondsSince1970] as [String : Any];
        
        amount += 1;
        ref.child("messages").child(messageKey!).child("\(amount)").setValue(paramSend);
        ref.child("messages").child(messageKey!).child("amount").setValue(amount);
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound();
        
        finishSendingMessage();
    }
}
