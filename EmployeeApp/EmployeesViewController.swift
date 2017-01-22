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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eManager = EmployeesManager()
        self.eManager?.doGetRequest(jsonUrl: <#T##String#>, httpMethod: "GET")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeTableCell
        
        return cell;
    }
    
    func employeesDataReceived(didComplete: Bool, data: [EmployeeInfo]?) {
        if didComplete != true {
            // Show alert.
        } else {
            self.employeesArray = data!
        }
    }

}
