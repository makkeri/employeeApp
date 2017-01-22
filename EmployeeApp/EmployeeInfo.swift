//
//  EmployeeInfo.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 22/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit

class EmployeeInfo: NSObject {
    
    public var name: String? = ""
    public var surname: String? = ""
    public var email: String? = ""
    public var photoUrl: String? = ""
    public var role: String? = ""
    public var organisation: String? = ""
    public var imageData: Data? = nil
    public var image: UIImage?
    
    override init() {
        
    }

    public func getFullName() -> String {
        return self.name! + " " + self.surname!
    }
}
