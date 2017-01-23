//
//  EmployeeAppTests.swift
//  EmployeeAppTests
//
//  Created by Marko Peitsila on 21/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import XCTest
@testable import EmployeeApp

class EmployeeAppTests: XCTestCase, EmployeesDataDelegate {
    
    var expectation: XCTestExpectation?
    var eManager: EmployeesManager?
    
    override func setUp() {
        super.setUp()
        self.eManager = EmployeesManager()
        self.eManager?.delegate = self;
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Unit test for gettin data.
    func testURLRequest() {
        expectation = expectation(description: "get")
        
        let eManager = EmployeesManager()
        eManager.doGetRequest(jsonUrl: "http://nielsmouthaan.nl/backbase/members.php", httpMethod: "GET")
        
        
        waitForExpectations(timeout: 60) { (error) in
            if error != nil {
                print("test error: \(error?.localizedDescription)")
            }
        }
    }
    
    func employeesDataReceived(didComplete: Bool, data: [EmployeeInfo]?, error: AppErrors) {
        if error == AppErrors.NoErrors {
            expectation?.fulfill()
        }
    }
    
}
