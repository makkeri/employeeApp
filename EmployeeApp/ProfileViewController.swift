//
//  ProfileViewController.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 22/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit

/* Profile View Controller. Populates View with employees data.
 */
class ProfileViewController: UIViewController {
    
    // Class variables
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var roleLabel: UILabel!
    @IBOutlet var departmentLabel: UILabel!
    @IBOutlet var mailMeImage: UIImageView!
    
    var employee: EmployeeInfo? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Taps gestures.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
        let tapGestureMailMe = UITapGestureRecognizer(target: self, action: #selector(sendMail(gesture:)))
        
        self.mailMeImage.addGestureRecognizer(tapGestureMailMe)
        self.mailMeImage.isUserInteractionEnabled = true

        self.setBackgroundImage()
        self.setBlur()
        
        self.populateUIElements()
        
        // Setup profile picture.
        self.profilePicture.addGestureRecognizer(tapGesture)
        self.profilePicture.isUserInteractionEnabled = true
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.borderWidth = 3.0
        self.profilePicture.layer.borderColor = UIColor.white.cgColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Private functions
    
    /* Set profile picture as background image, if profile picture is missing add default BG image instead.
     */
    private func setBackgroundImage() {
        var image: UIImage?
        if self.employee?.imageData != nil {
            image = UIImage(data:(self.employee?.imageData)!)
        } else {
            image = UIImage(named: "green_dino")
        }
        
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        
        self.view.insertSubview(imageView, belowSubview: profilePicture)
    }
    
    /* The blur effect of background image.
     */
    private func setBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurEffectView, belowSubview: profilePicture)
    }
    
    /* Show user profile data.
     */
    private func populateUIElements() {
        if self.employee?.imageData != nil {
            let image = UIImage(data: (self.employee?.imageData)!)
            self.profilePicture.image = image
            
        } else {
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
    
    //MARK: - Actions
    
    /* Action for button to open default email application with email already to added.
     */
    func sendMail(gesture: UITapGestureRecognizer) {
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
    
    /* Open image viewer
     */
    func imageTapped(gesture: UITapGestureRecognizer) {
        if self.employee?.imageData != nil {
            let profileViewerCV = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewer") as! ImageViewerViewController
            profileViewerCV.imageData = self.employee?.imageData
            self.present(profileViewerCV, animated: true, completion: nil)
        } else {
            print("No image to show.")
        }
    }
    
    /* Back button navigation.
     */
    @IBAction func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}


