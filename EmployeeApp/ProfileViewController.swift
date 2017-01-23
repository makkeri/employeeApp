//
//  ProfileViewController.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 22/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit

/* 
 */
class ProfileViewController: UIViewController {
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var roleLabel: UILabel!
    @IBOutlet var departmentLabel: UILabel!
    
    var employee: EmployeeInfo? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateUIElements()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* Back button navigation.
     */
    @IBAction func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /* Show user profile data.
     */
    private func populateUIElements() {
        if self.employee?.imageData != nil {
            let image = UIImage(data: (self.employee?.imageData)!)
            self.profilePicture.image = image
            
        } else {
            print("Missing profile picture.")
            self.profilePicture.image = #imageLiteral(resourceName: "default_profile")
        }
        
        guard self.employee?.getFullName() != nil,
              self.employee?.role != nil,
              self.employee?.organisation != nil
        else {
            print("Information missing")
            return
        }
        
        self.nameLabel.text = self.employee?.getFullName()
        self.roleLabel.text = self.employee?.role
        self.departmentLabel.text = self.employee?.organisation
    }
    
    @IBAction func sendMail() {
        if self.employee?.email != nil {
            let emailAddress = self.employee?.email!
            let email = "mailto:\(emailAddress!)"
            
            if let emailURL = NSURL(string: email) {
                if UIApplication.shared.canOpenURL(emailURL as URL) {
                    UIApplication.shared.openURL(emailURL as URL)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Cannot open email application.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}
