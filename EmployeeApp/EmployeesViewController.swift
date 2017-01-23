//
//  EmplyeesViewController.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 21/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit

/* This class controls main UITableView and cells.
 */
class EmplyeesViewController: UITableViewController, EmployeesDataDelegate {

    let jsonURL = "http://nielsmouthaan.nl/backbase/members.php"
    
    var employeesArray: [EmployeeInfo?] = []
    var sectionArray: [String?] = []
    var eManager: EmployeesManager?
    
    struct sectionObjects {
        var sectionName: String!
        var sectionObject: [EmployeeInfo?]
    }
    
    var objectArray = [sectionObjects]()
    
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
        // return self.objectArray.count;
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.employeesArray.count;
        // return objectArray[section].sectionObject.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeTableCell
        
        // let employee = objectArray[indexPath.section].sectionObject[indexPath.row] // employeesArray[indexPath.row]
        let employee = employeesArray[indexPath.row]
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let row = indexPath.row
//        print("Clicked Index: \(employeesArray[row]?.name)")
        
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return objectArray[section].sectionName
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileView" {
            let destinationVC = segue.destination as! UINavigationController
            let targetVC = destinationVC.topViewController as! ProfileViewController
            let employeeIndex = self.tableView.indexPathForSelectedRow?.row
            targetVC.employee = self.employeesArray[employeeIndex!]
        }
    }
    
    //MARK: - EmployeeManager delegate methods.
    
    func employeesDataReceived(didComplete: Bool, data: [EmployeeInfo]?, message: String) {
        if didComplete != true {
            // Show alert.
        } else {
            self.employeesArray = data!
            self.tableView.reloadData()
            
            guard (eManager?.sections.count)! > 0 else {
                print("Cannot find sections.")
                return
            }
            self.sectionArray = (eManager?.sections)!
            
            //self.setSections()
        }
    }
    
    private func setSections() {
        
        // Collect employees by
        var sectionsDictionary = Dictionary<String, [EmployeeInfo]>()
        for section in self.sectionArray {
            print("section: \(section)")
            
            var arr: [EmployeeInfo] = []
            for emp in self.employeesArray {
                
                if emp?.organisation == section! {
                    arr.append(emp!)
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

}
