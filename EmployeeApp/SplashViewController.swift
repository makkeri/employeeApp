//
//  SplashViewController.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 23/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit

/* SplashScreen class.
 */
class SplashViewController: UIViewController {

    @IBOutlet var appIcon: UIImageView!
    @IBOutlet var label: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackgroundImage()
        
        // Little animation for appIcon and label to show.
        UIView.animate(withDuration: 2.0, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.appIcon.alpha = 1.0
            self.label?.alpha = 1.0
        }, completion: nil)
    }
    
    /* Set background image.
     */
    private func setBackgroundImage() {
        var image: UIImage?
        image = UIImage(named: "gradient3_bg")
        
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        
        self.view.insertSubview(imageView, belowSubview: self.appIcon)
    }

}
