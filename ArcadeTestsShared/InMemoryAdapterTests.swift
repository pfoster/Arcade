//
//  InMemoryAdapterTests.swift
//  Arcade
//
//  Created by A.C. Wright Design on 11/1/17.
//  Copyright © 2017 A.C. Wright Design. All rights reserved.
//

import XCTest
@testable import Arcade

class InMemoryAdapterTests: XCTestCase {
    
    var adapter: InMemoryAdapter!

    override func setUp() {
        super.setUp()
        self.adapter = InMemoryAdapter()
    }
    
    override func tearDown() {
        self.adapter = nil
        super.tearDown()
    }
    
    func testCanInitialize() {
        XCTAssertNotNil(self.adapter)
    }
    
    func testCanConnect() {
        let expectation = XCTestExpectation(description: "Connect")
        
        self.adapter.connect().subscribe(onNext: { (success) in
            XCTAssertTrue(success)
            expectation.fulfill()
        }) { (error) in
            XCTFail(error.localizedDescription)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCanDisconnect() {
        let expectation = XCTestExpectation(description: "Connect")
        
        self.adapter.disconnect().subscribe(onNext: { (success) in
            XCTAssertTrue(success)
            expectation.fulfill()
        }) { (error) in
            XCTFail(error.localizedDescription)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCanInsert() {
        let expectation = XCTestExpectation(description: "Insert")
        
        let widget = Widget(uuid: UUID(), name: "Test")
        
        self.adapter.insert(table: WidgetTable.widget, storable: widget).subscribe(onNext: { (success) in
            XCTAssertTrue(success)
            expectation.fulfill()
        }) { (error) in
            XCTFail(error.localizedDescription)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCanFind() {
        let expectation = XCTestExpectation(description: "Find")
        
        let widget = Widget(uuid: UUID(), name: "Test")
        
        self.adapter.insert(table: WidgetTable.widget, storable: widget).flatMap({ (success) -> Future<Widget?> in
            XCTAssertTrue(success)
            return self.adapter.find(table: WidgetTable.widget, uuid: widget.uuid)
        }).subscribe(onNext: { (widget) in
            XCTAssertNotNil(widget)
            expectation.fulfill()
        }) { (error) in
            XCTFail(error.localizedDescription)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCanFetch() {
        let expectation = XCTestExpectation(description: "Fetch")
        
        let widget = Widget(uuid: UUID(), name: "Test")
        
        let expression = Expression.equal("name", "Test")
        let query = Query.expression(expression)
        
        self.adapter.insert(table: WidgetTable.widget, storable: widget).flatMap({ (success) -> Future<[Widget]> in
            XCTAssertTrue(success)
            return self.adapter.fetch(table: WidgetTable.widget, query: query)
        }).subscribe(onNext: { (widgets) in
            XCTAssertEqual(widgets.count, 1)
            expectation.fulfill()
        }) { (error) in
            XCTFail(error.localizedDescription)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCanUpdate() {
        let expectation = XCTestExpectation(description: "Find")
        
        var widget = Widget(uuid: UUID(), name: "Test")
        
        self.adapter.insert(table: WidgetTable.widget, storable: widget).flatMap({ (success) -> Future<Widget?> in
            XCTAssertTrue(success)
            return self.adapter.find(table: WidgetTable.widget, uuid: widget.uuid)
        }).flatMap({ (fetchedWidget) -> Future<Bool> in
            XCTAssertNotNil(fetchedWidget)
            
            widget.name = "Foo"
            
            return self.adapter.update(table: WidgetTable.widget, storable: widget)
        }).flatMap({ (success) -> Future<Widget?> in
            XCTAssertTrue(success)
            return self.adapter.find(table: WidgetTable.widget, uuid: widget.uuid)
        }).subscribe(onNext: { (fetchedWidget) in
            XCTAssertNotNil(fetchedWidget)
            XCTAssertEqual(fetchedWidget?.name, "Foo")
            expectation.fulfill()
        }) { (error) in
            XCTFail(error.localizedDescription)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCanDelete() {
        let expectation = XCTestExpectation(description: "Find")
        
        let widget = Widget(uuid: UUID(), name: "Test")
        
        self.adapter.insert(table: WidgetTable.widget, storable: widget).flatMap({ (success) -> Future<Bool> in
            XCTAssertTrue(success)
            return self.adapter.delete(table: WidgetTable.widget, storable: widget)
        }).flatMap({ (success) -> Future<Int> in
            XCTAssertTrue(success)
            return self.adapter.count(table: WidgetTable.widget, query: nil)
        }).subscribe(onNext: { (count) in
            XCTAssertEqual(count, 0)
            expectation.fulfill()
        }) { (error) in
            XCTFail(error.localizedDescription)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCanCount() {
        let expectation = XCTestExpectation(description: "Count")
        
        let widget = Widget(uuid: UUID(), name: "Test")
        
        let expression = Expression.equal("name", "Test")
        let query = Query.expression(expression)
        
        self.adapter.insert(table: WidgetTable.widget, storable: widget).flatMap({ (success) -> Future<Int> in
            XCTAssertTrue(success)
            return self.adapter.count(table: WidgetTable.widget, query: query)
        }).subscribe(onNext: { (count) in
            XCTAssertEqual(count, 1)
            expectation.fulfill()
        }) { (error) in
            XCTFail(error.localizedDescription)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

}
