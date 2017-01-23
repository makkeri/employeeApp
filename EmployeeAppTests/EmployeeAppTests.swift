//
//  EmployeeAppTests.swift
//  EmployeeAppTests
//
//  Created by Marko Peitsila on 21/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import XCTest
@testable import EmployeeApp

class EmployeeAppTests: XCTestCase {
    
    var expectation: XCTestExpectation?
    var eManager: EmployeesManager?
    var sessionDataTask: URLSessionDataTask?
    
    override func setUp() {
        super.setUp()
        self.eManager = EmployeesManager()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Unit test for gettin data.
    func testURLRequest() {
        expectation = expectation(description: "get")
        
        var request = URLRequest.init(url: URL(string: "http://nielsmouthaan.nl/backbase/members.php")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Get data from request url.
        self.sessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                // If some errors, send false and nil to delegate.
                print("error: \(error?.localizedDescription)")
            } else {
                self.expectation?.fulfill()
            }
        })
        
        self.sessionDataTask?.resume()
        
        waitForExpectations(timeout: 60) { (error) in
            if error != nil {
                print("test error: \(error?.localizedDescription)")
            }
        }
    }
}
