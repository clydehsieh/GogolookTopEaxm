//
//  ItemRequestState.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

class ItemRequestState {
    var type: String?
    var filter: String?
    var currentPage: Int = ItemRequestState.beginPage
    var hasNextPage: Bool = true
}

extension ItemRequestState {
    var nextPage: Int? {
        if hasNextPage {
            return currentPage + 1
        }
        return nil
    }
    
    static let beginPage = 1
}
