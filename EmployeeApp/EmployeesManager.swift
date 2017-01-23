//
//  EmployeesManager.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 22/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit
import Foundation

/* Delegate function to notify Main view for UI updated. And error messaging.
 */
protocol EmployeesDataDelegate {
    func employeesDataReceived(didComplete: Bool, data: [EmployeeInfo]?, message: String)
}

/* This class request employees from given URL and parses data to EmployeeInfo objects.
 * Data needs to be in JSON for parser to work.
 *
 * After received JSON nad parsed, starts the profile picture download, and when image is downloaded
 * UI is updated for new data.
 */
class EmployeesManager: NSObject {
    
    // Delegate variable
    var delegate: EmployeesDataDelegate? = nil
    
    // URL session variables.
    let session: URLSession = URLSession.shared
    var sessionDataTask: URLSessionDataTask?
    var sections: [String?] = []
    
    // List of all employees.
    var employeesInfoArray: [EmployeeInfo] = []
    
    struct sectionObjects {
        var sectionName: String!
        var sectionObject: [EmployeeInfo?]
    }
    
    var objectArray = [sectionObjects]()
    
    //MARK: - Public functions
    
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

    //MARK: - Private functions
    
    /* Parse JSON from received data to dictionary.
     */
    private func parseJSON(jsonData: Data) {
        
        do {
            // Serialize json
            let parsedJson = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions()) as! NSDictionary
            
            self.sections = parsedJson.allKeys as! [String]
            
            // Parse JSON and do employeeInfo objects.
            for key in parsedJson.allKeys {
                if let array = parsedJson[key] {
                    self.createEmployeeInfo(key: key as! String, array: array as! Array<Dictionary<String, Any>>)
                }
            }
            
            
//            let dlGroup = DispatchGroup()
//            
//            for employee in self.employeesInfoArray {
//                
//                dlGroup.enter()
//                
//                self.downloadImage(emp: employee)
//            }
            
            // Download profile pictures when parsing is done.
            self.downloadImage(emp: self.employeesInfoArray)
            
            //self.updateTableView()

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
        
    }
    
    /* Downloads image from the URL. And the URL is constructed from baseUrl and employees profile image Url from EmployeeInfo.
     */
    private func downloadImage(emp: [EmployeeInfo?]) {

        for employee in emp {
            if employee?.photoUrl != nil {
                let baseUrl = "http://nielsmouthaan.nl/backbase/photos/"
                let photoUrl: String? = baseUrl + (employee?.photoUrl!)!
                if let imageUrl: URL = URL(string: photoUrl!) {
                    print("\(imageUrl)")
                    
                    // Get image in own thread.
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let imageData: NSData = NSData(contentsOf: imageUrl) {
                            employee?.imageData = imageData as Data
                        }
                        
                        // When image recieved update UI.
                        self.updateTableView()
                    }
                }
            }
        }
    }
    
    private func setSections() {
        
        // Collect employees by
        var sectionsDictionary = Dictionary<String, [EmployeeInfo]>()
        for section in self.sections {
            print("section: \(section)")
            
            var arr: [EmployeeInfo] = []
            for emp in self.employeesInfoArray {
                
                if emp.organisation == section! {
                    arr.append(emp)
                }
            }
            sectionsDictionary[section!] = arr
        }
        
        print("Sections: \(sectionsDictionary)")
        
        for (key, value) in sectionsDictionary {
            print("\(key) -> \(value)")
            objectArray.append(sectionObjects(sectionName: key, sectionObject: value))
        }
    }
    
    // Call delegate to update UI.
    private func updateTableView() {
        DispatchQueue.main.async {
            self.delegate?.employeesDataReceived(didComplete: true, data: self.employeesInfoArray, message: "Update.")
        }
    }
}
