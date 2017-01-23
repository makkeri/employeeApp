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
    
    /* Close view.
     */
    func close(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}
