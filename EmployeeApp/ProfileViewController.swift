//
//  ProfileViewController.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 22/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit

protocol ProfileViewDelegate {
    func dismissProfileView(controller: UIViewController)
}

class ProfileViewController: UIViewController {
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var roleLabel: UILabel!
    @IBOutlet var departmentLabel: UILabel!
    
    
    var employee: EmployeeInfo? = nil
    
    var delegate: ProfileViewDelegate? = nil;

    override func viewDidLoad() {
        super.viewDidLoad()

//        let backButton =  UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(UIWebView.goBack))
//        self.navigationItem.leftBarButtonItem = backButton
        
        self.populateUIElements()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func populateUIElements() {
        if self.employee?.imageData != nil {
            // self.profilePicture.image = UIImage(data:(self.employee?.imageData)!)
            
            let image = UIImage(data: (self.employee?.imageData)!)
            
            self.profilePicture.contentMode = UIViewContentMode.scaleAspectFit
            
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

}
