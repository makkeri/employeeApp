//
//  EmplyeesViewController.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 21/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit

class EmplyeesViewController: UITableViewController, EmployeesDataDelegate {

    let jsonURL = "http://nielsmouthaan.nl/backbase/members.php"
    
    var employeesArray: [EmployeeInfo?] = []
    var eManager: EmployeesManager?
    
    //MARK: - Override functions.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        
        self.eManager = EmployeesManager()
        
        self.eManager?.delegate = self
        
        self.eManager?.doGetRequest(jsonUrl: jsonURL, httpMethod: "GET")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.employeesArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeTableCell
        
        
        let employee = employeesArray[indexPath.row]
        cell.nameLabel.text = employee?.getFullName()
        
        cell.nameLabel.textColor = UIColor.darkGray
        if employee?.imageData != nil {
            cell.profilePicture.image = UIImage(data: (employee?.imageData)!)
        } else {
            cell.profilePicture.image = #imageLiteral(resourceName: "default_profile")
        }
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        print("Clicked Index: \(employeesArray[row]?.name)")
        
    }
    
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
        }
    }

}
