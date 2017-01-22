//
//  EmployeesManager.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 22/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit
import Foundation

protocol EmployeesDataDelegate {
    func employeesDataReceived(didComplete: Bool, data: [EmployeeInfo]?, message: String)
}

class EmployeesManager: NSObject {
    
    // Delegate variable
    var delegate: EmployeesDataDelegate? = nil
    
    // URL session variables.
    let session: URLSession = URLSession.shared
    var sessionDataTask: URLSessionDataTask?
    
    // List of all employees.
    var employeesInfoArray: [EmployeeInfo] = []
    
    /* This function creates http request and exceute it.
     * @param jsonUrl, the url of json content
     * @param httpMethod, request method (GET, POST, PUT, etc.)
     */
    public func doGetRequest(jsonUrl: String, httpMethod: String) {
        
        // Check if sessionDataTask is already initialized. If so, cancel it before reuse.
        if sessionDataTask != nil {
            sessionDataTask?.cancel()
        }
        
        // Create URL request and gice params to it.
        var request = URLRequest.init(url: URL(string: jsonUrl)!)
        request.httpMethod = httpMethod
        request.timeoutInterval = 30
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Get data from request url.
        self.sessionDataTask = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                // If some errors, send false and nil to delegate.
                let errorMsg = "error: \(error?.localizedDescription)"
                self.delegate?.employeesDataReceived(didComplete: false, data: nil, message: errorMsg)
            } else {
                self.parseJSON(jsonData: data!)
            }
        })
        
        self.sessionDataTask?.resume()
    }

    /* Parse JSON from received data to dictionary.
     */
    private func parseJSON(jsonData: Data) {
        
        do {
            // Serialize json
            let parsedJson = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions()) as! NSDictionary
            
            // Parse JSON and do employeeInfo objects.
            for key in parsedJson.allKeys {
                if let array = parsedJson[key] {
                    self.createEmployeeInfo(key: key as! String, array: array as! Array<Dictionary<String, Any>>)
                }
            }
            
            // Download profile pictures.
            for employee in self.employeesInfoArray {
                self.getImage(emp: employee)
            }

        } catch let error as Error? {
            let errorMSG = "Error when serializing JSON: \(error?.localizedDescription)"
            print("\(errorMSG)")
            self.delegate?.employeesDataReceived(didComplete: false, data: nil, message: errorMSG)
        }
    }
    
    /* Populate employeesInfoArray with Eployee object.
     */
    private func createEmployeeInfo(key: String, array: Array<Dictionary<String, Any>>) {
        
        // Create employee object for every employee from the received data.
        for item in array {
            let employee = EmployeeInfo()
            employee.name = item["name"] as? String
            employee.surname = item["surname"] as? String
            employee.photoUrl = item["photo"] as? String
            employee.role = item["role"] as? String
            employee.email = item["email"] as? String
            employee.organisation = key
            self.employeesInfoArray.append(employee)
        }
        
        // Update UI.
//        DispatchQueue.main.async {
//            self.delegate?.employeesDataReceived(didComplete: true, data: self.employeesInfoArray)
//        }
        // self.updateTableView()
        
    }
    
    private func getImage(emp: EmployeeInfo!) {

        if emp.photoUrl != nil {
            let baseUrl = "http://nielsmouthaan.nl/backbase/photos/"
            let photoUrl: String? = baseUrl + emp.photoUrl!
            if let imageUrl: URL = URL(string: photoUrl!) {
                print("\(imageUrl)")
                
                DispatchQueue.global(qos: .userInitiated).async {
                    if let imageData: NSData = NSData(contentsOf: imageUrl) {
                        emp.imageData = imageData as Data
                    }
                    
                    self.updateTableView()
                }
            }
            
            
        }
    }
    
    // Call delegate to update UI.
    private func updateTableView() {
        DispatchQueue.main.async {
            self.delegate?.employeesDataReceived(didComplete: true, data: self.employeesInfoArray, message: "Update.")
        }
    }
    
    private func downloadProfilePictures(employee: EmployeeInfo) {
        let baseUrl = "http://nielsmouthaan.nl/backbase/photos/"
        if employee.photoUrl != nil {
            let imageUrl = baseUrl + employee.photoUrl!
            
            if sessionDataTask != nil {
                sessionDataTask?.cancel()
            }
            
            self.sessionDataTask =  self.session.dataTask(with: URL(string: imageUrl)!, completionHandler: { (data, response, error) in
                if error != nil {
                    // self.delegate?.employeesDataReceived(didComplete: false, data: <#T##[EmployeeInfo]?#>, message: <#T##String#>)
                    print("Error when downloading profile image: \(error?.localizedDescription)")
                } else {
                    employee.imageData = data
                }
            })
            
            self.sessionDataTask?.resume()
            
        } else {
            print("No profile picture, use default.")
        }
        
    }
}
