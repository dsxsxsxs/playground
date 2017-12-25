//
//  playgroundTests.swift
//  playgroundTests
//
//  Created by dsxs on 2017/12/22.
//  Copyright © 2017年 dsxs. All rights reserved.
//

import XCTest
@testable import playground

class playgroundTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        guard let orz = Orz(name: "playground.db", use:DispatchQueue.main) else{
            XCTAssert(false, "failed to open db")
            return
        }
        let exp = expectation(description: "green lights")
        orz.drop(model: TestModel()) { rs in
            orz.create(model: TestModel()) { rs in
                switch rs{
                case .failed(let err):
                    XCTAssert(false, "\(err) failed to create table db")
                case .done:
                    let m = TestModel(id:0, created_at: Date(), title: "fefef")
                    orz.insert(model: m) { rs in
                        switch rs{
                        case .failed(let err):
                            XCTAssert(false, "\(err) failed to create table db")
                        case .done:
                            orz.select(from: TestModel(), where: ""){ rs in
                                switch rs{
                                case .failed(let err):
                                    XCTAssert(false, "\(err) failed to create table db")
                                case .done:
                                    break
                                case .data(let models):
                                    XCTAssert(models.count > 0, "db no data")
                                    break
                                }
                                exp.fulfill()
                            }
                            
                        case .data(_):
                            break
                        }
                        
                    }
                    
                case .data(_):
                    break
                }
                
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
