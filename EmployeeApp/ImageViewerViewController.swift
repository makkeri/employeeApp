//
//  ImageViewerViewController.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 23/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit

class ImageViewerViewController: UIViewController {

    @IBOutlet var profileImageView: UIImageView!
    public var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.setBackgroundImage()
        
        self.view.backgroundColor = UIColor.black
        
        self.setImage(image: UIImage(data: self.imageData!)!)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close(gesture:)))

        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(tapGesture)
        
    }
    
    /* Set image.
     */
    private func setImage(image: UIImage) {
        if self.imageData != nil {
            self.profileImageView.image = image
            self.profileImageView.contentMode = .scaleAspectFit
        }
    }
    
    private func setBackgroundImage() {
        let image = UIImage(named: "gradient3_bg")
        
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        
        self.view.insertSubview(imageView, belowSubview: self.profileImageView)
    }
    
    /* Close view.
     */
    func close(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}
