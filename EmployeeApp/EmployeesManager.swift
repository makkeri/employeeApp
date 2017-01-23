//
//  EmployeesManager.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 22/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit
import SystemConfiguration
import Foundation

/* Delegate function to notify Main view for UI updated. And error messaging.
 */
protocol EmployeesDataDelegate {
    func employeesDataReceived(didComplete: Bool, data: [EmployeeInfo]?, error: AppErrors)
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
    
    var sectionsDictionary = Dictionary<String, [EmployeeInfo]>()
    var sections: [String?] = []
    
    // List of all employees.
    var employeesInfoArray: [EmployeeInfo] = []
    
    public struct sectionObjects {
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
        
        // Check internet connection.
        if self.checkInternetConnection() == false {
            self.delegate?.employeesDataReceived(didComplete: false, data: nil, error: AppErrors.NetworkError)
            return
        }
        
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
                self.delegate?.employeesDataReceived(didComplete: false, data: nil, error: AppErrors.NetworkError)
            } else {
                self.parseJSON(jsonData: data!)
            }
        })
        
        self.sessionDataTask?.resume()
    }

    //MARK: - Private functions
    
    /* Check if network is available.
     */
    private func checkInternetConnection() -> Bool {
        
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout.size(ofValue: address))
        address.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &address, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection);
    }
    
    /* Parse JSON from received data to dictionary.
     */
    private func parseJSON(jsonData: Data) {
        
        do {
            // Serialize json
            let parsedJson = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions()) as! NSDictionary
            
            // Save Sections.
            self.sections = parsedJson.allKeys as! [String]
            
            // Parse JSON and do employeeInfo objects.
            if self.sections.count == 0 {
                self.createEmployeeInfo(key: "", array: [parsedJson as! Dictionary<String, Any>])
            } else {
                for key in parsedJson.allKeys {
                    if let array = parsedJson[key] {
                        self.createEmployeeInfo(key: key as! String, array: array as! Array<Dictionary<String, Any>>)
                    }
                }
            }
            
            // Download profile pictures when parsing is done.
            self.downloadImage(emp: self.employeesInfoArray)
            
            //self.updateTableView()

        } catch let error as Error? {
            let errorMSG = "Error when serializing JSON: \(error?.localizedDescription)"
            print("\(errorMSG)")
            self.delegate?.employeesDataReceived(didComplete: false, data: nil, error: AppErrors.ParsingError)
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

        // Create DispatchGroup to download images.
        let dlGroup = DispatchGroup()
        
        for employee in emp {
            
            // Enter group to download image in bacground thread.
            dlGroup.enter()
            
            if employee?.photoUrl != nil {
                let baseUrl = "http://nielsmouthaan.nl/backbase/photos/"
                let photoUrl: String? = baseUrl + (employee?.photoUrl!)!
                if let imageUrl: URL = URL(string: photoUrl!) {
                    
                    // Get image in own thread.
                    if let imageData: NSData = NSData(contentsOf: imageUrl) {
                        employee?.imageData = imageData as Data
                    }
                    
                    dlGroup.leave()
                }
            }
        }
        
        // Wait all that all group thread are ended and continue.
        DispatchGroup().notify(queue: DispatchQueue.main) {
            self.setSections()
            self.updateTableView()
        }
    }
    
    /* Divide employees by the department(section)
     */
    private func setSections() {
        for section in self.sections {
            var arr: [EmployeeInfo] = []
            for emp in self.employeesInfoArray {
                
                if emp.organisation == section! {
                    arr.append(emp)
                }
            }
            self.sectionsDictionary[section!] = arr
        }
    }
    
    // Call delegate to update UI.
    private func updateTableView() {
        DispatchQueue.main.async {
            print("UPDATE CALLED")
            self.delegate?.employeesDataReceived(didComplete: true, data: self.employeesInfoArray, error: AppErrors.NoErrors)
        }
    }
}
