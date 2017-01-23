//
//  EmplyeesViewController.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 21/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit

enum AppErrors {
    case NetworkError;
    case ParsingError;
    case NoErrors;
}

/* This class controls main UITableView and cells.
 */
class EmplyeesViewController: UITableViewController, EmployeesDataDelegate {

    let jsonURL = "http://nielsmouthaan.nl/backbase/members.php"

    var sectionArray: [String?] = []
    var eManager: EmployeesManager?
    
    struct sectionEmployees {
        var sectionName: String!
        var sectionObject: [EmployeeInfo?]
    }
    
    var employeesArray = [sectionEmployees]()
    
    //MARK: - Override functions.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Autolayout for cells.
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        
        // Init eMamager and add delegate, then start requesting content.
        self.eManager = EmployeesManager()
        self.eManager?.delegate = self
        self.eManager?.doGetRequest(jsonUrl: jsonURL, httpMethod: "GET")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.employeesArray.count;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeesArray[section].sectionObject.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeTableCell
        
        let employee = employeesArray[indexPath.section].sectionObject[indexPath.row]
        
        // Set employee name.
        cell.nameLabel.text = employee?.getFullName()
        
        // Text color
        cell.nameLabel.textColor = UIColor.darkGray
        
        // Set thumbnail.
        if employee?.imageData != nil {
            cell.profilePicture.image = UIImage(data: (employee?.imageData)!)
        } else {
            // If there is no profile picture use default instead.
            cell.profilePicture.image = #imageLiteral(resourceName: "default_profile")
        }
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return employeesArray[section].sectionName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileView" {
            let destinationVC = segue.destination as! UINavigationController
            let targetVC = destinationVC.topViewController as! ProfileViewController
            let section = self.tableView.indexPathForSelectedRow?.section
            let employeeIndex = self.tableView.indexPathForSelectedRow?.row
            
            // Pass selected employee to ProfileView
            targetVC.employee = employeesArray[section!].sectionObject[employeeIndex!]
        }
    }
    
    //MARK: - EmployeeManager delegate methods.
    
    func employeesDataReceived(didComplete: Bool, data: [EmployeeInfo]?, error: AppErrors) {
        if didComplete != true {
            
            // Some error handling with UIAlerController.
            let alert: UIAlertController?
            var errorMsg: String = ""
            
            switch error {
            case .NetworkError:
                errorMsg = "Network error! \n Plase make sure you have network connection."
                break
                
            case .ParsingError:
                errorMsg = "Parsing error! \n Oops something went wrong when parsing content."
                break
                
            default:
                break
            }
            
            alert = UIAlertController(title: "Error", message: errorMsg,
                                      preferredStyle: UIAlertControllerStyle.alert)
            
            // Add refresh button
            alert?.addAction(UIAlertAction(title: "Refresh", style: .default, handler: { (action) in
                self.eManager?.doGetRequest(jsonUrl: self.jsonURL, httpMethod: "GET")
            }))
            
            // Add cancel button
            alert?.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            self.present(alert!, animated: true, completion: nil)
        } else {
            self.setSections()
        }
    }
    
    /* Create object array with sections and section objects(employees)
     */
    private func setSections() {
        
        let sectionsDictionary = eManager?.sectionsDictionary
        
        for (key, value) in sectionsDictionary! {
            print("\(key) -> \(value)")
            self.employeesArray.append(sectionEmployees(sectionName: key, sectionObject: value))
        }
        
        self.tableView.reloadData()
    }

}
