//
//  StyleSettingsViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-30.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class StyleSettingsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    var style : Style?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.allowsMultipleSelectionDuringEditing = false;
    }
    
    
    // Segue into new view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EditStyleSegue")
        {
            // If style is not empty, that means we are editing a style so we tell the view controller that we are
            if (style != nil)
            {
                let vc = segue.destination as! NewStyleViewController;
                
                vc.style = style;
                vc.new = false;
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        self.tableView.reloadData();
        style = nil;
    }
    
    @IBAction func backButton(sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (mainUser as! Shop).styles.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewStyleCell", for: indexPath) as! ViewStyleCell;

        let style = (mainUser as! Shop).styles[indexPath.row];
        
        cell.styleName.text = style.name;
        cell.stylePrice.text = "Price: $\(String(format: "%.02f", style.price))";
        cell.styleTime.text = "Time: \(timeIntervals[style.time])";
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete)
        {
            let ref = Database.database().reference();
            
            let style = (mainUser as! Shop).styles[indexPath.row];
            (mainUser as! Shop).styles.remove(at: indexPath.row);
            
            ref.child("users").child(mainUser.key).child("styles").child(style.name).removeValue();
            
            tableView.deleteRows(at: [indexPath], with: .automatic);
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        style = (mainUser as! Shop).styles[indexPath.row];
        
        self.performSegue(withIdentifier: "EditStyleSegue", sender: self);
    }
}
