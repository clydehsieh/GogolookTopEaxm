//
//  ItemRequestTest.swift
//  GogolookExamTests
//
//  Created by ClydeHsieh on 2022/5/19.
//

import XCTest
@testable import GogolookExam

class ItemRequestTest: XCTestCase {

    func testListTypeByDefault() {
        let itemRequest: ItemRequest = .defaultConfig
        XCTAssertEqual(itemRequest.listType, ItemListType.anime)
    }

    func testTypeByDefault() {
        let itemRequest: ItemRequest = .defaultConfig
        XCTAssertEqual(itemRequest.type, nil)
    }
    
    func testFilterByDefault() {
        let itemRequest: ItemRequest = .defaultConfig
        XCTAssertEqual(itemRequest.filter, nil)
    }
    
    func testPageByDefault() {
        let itemRequest: ItemRequest = .defaultConfig
        XCTAssertEqual(itemRequest.page, 0)
    }
}
