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
    func employeesDataReceived(didComplete: Bool, data: [EmployeeInfo]?)
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
                print("error: \(error?.localizedDescription)")
                self.delegate?.employeesDataReceived(didComplete: false, data: nil)
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
            
            let parsedJson = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions()) as! NSDictionary
            
            for key in parsedJson.allKeys {
                if let array = parsedJson[key] {
                    // self.tmp(array: array as! Array<Dictionary<String, Any>>)
                    self.createEmployeeInfo(key: key as! String, array: array as! Array<Dictionary<String, Any>>)
                }
            }
            
            // If the list are populated, send it to the main view.
            if self.employeesInfoArray.count > 0 {
                self.delegate?.employeesDataReceived(didComplete: true, data: self.employeesInfoArray)
            }
            
        } catch {
            print("Error with JSON serialization")
            self.delegate?.employeesDataReceived(didComplete: false, data: nil)
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
        
    }
}
